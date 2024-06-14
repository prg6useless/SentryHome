from io import BytesIO
from fastapi import FastAPI, Request, BackgroundTasks
from fastapi.responses import StreamingResponse, HTMLResponse
import io
import cv2
import numpy as np
from starlette.middleware.cors import CORSMiddleware
import asyncio
from datetime import datetime
from ultralytics import YOLOv10
import supervision as sv
import firebase_admin
from firebase_admin import credentials, storage, firestore
import os
from io import BytesIO
import uuid

app = FastAPI()

frame = None
video_writer = None
output_filename = 'output_video.mp4'
video_writer_initialized = False

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)

MODEL_PATH = 'yolov10n.pt'
model = YOLOv10(MODEL_PATH)

category_dict = {
    0: 'person', 1: 'bicycle', 2: 'car', 3: 'motorcycle', 4: 'airplane', 5: 'bus',
    6: 'train', 7: 'truck', 8: 'boat', 9: 'traffic light', 10: 'fire hydrant',
    11: 'stop sign', 12: 'parking meter', 13: 'bench', 14: 'bird', 15: 'cat',
    16: 'dog', 17: 'horse', 18: 'sheep', 19: 'cow', 20: 'elephant', 21: 'bear',
    22: 'zebra', 23: 'giraffe', 24: 'backpack', 25: 'umbrella', 26: 'handbag',
    27: 'tie', 28: 'suitcase', 29: 'frisbee', 30: 'skis', 31: 'snowboard',
    32: 'sports ball', 33: 'kite', 34: 'baseball bat', 35: 'baseball glove',
    36: 'skateboard', 37: 'surfboard', 38: 'tennis racket', 39: 'bottle',
    40: 'wine glass', 41: 'cup', 42: 'fork', 43: 'knife', 44: 'spoon', 45: 'bowl',
    46: 'banana', 47: 'apple', 48: 'sandwich', 49: 'orange', 50: 'broccoli',
    51: 'carrot', 52: 'hot dog', 53: 'pizza', 54: 'donut', 55: 'cake',
    56: 'chair', 57: 'couch', 58: 'potted plant', 59: 'bed', 60: 'dining table',
    61: 'toilet', 62: 'tv', 63: 'laptop', 64: 'mouse', 65: 'remote', 66: 'keyboard',
    67: 'cell phone', 68: 'microwave', 69: 'oven', 70: 'toaster', 71: 'sink',
    72: 'refrigerator', 73: 'book', 74: 'clock', 75: 'vase', 76: 'scissors',
    77: 'teddy bear', 78: 'hair drier', 79: 'toothbrush'
}

# Initialize Firebase Admin SDK
# Path to your downloaded JSON key file
cred = credentials.Certificate("serviceAccountkey.json")
firebase_admin.initialize_app(cred, {
    # Replace with your Firebase project ID
    'storageBucket': 'sentryhome-a95cd.appspot.com'
})

db = firestore.client()


def save_detection_event(class_id, confidence, frame):
    if class_id in [0, 3, 7]:  # person, motorcycle, truck
        timestamp = datetime.now().isoformat()
        # Generate a unique ID for the event and image
        unique_id = str(uuid.uuid4())

        # Create a filename for the image
        image_filename = f"detection_{unique_id}.jpg"

        # Convert the frame to a byte stream
        _, image_encoded = cv2.imencode('.jpg', frame)
        image_stream = BytesIO(image_encoded)

        # Upload the image to Firebase Storage in the specified subdirectory
        bucket = storage.bucket()
        blob = bucket.blob(f'detection_images/{image_filename}')
        blob.upload_from_file(image_stream, content_type='image/jpeg')
        blob.make_public()  # Make the image public

        # Get the public URL of the image
        image_url = blob.public_url

        # Event data to save in Firestore
        event_data = {
            'object': category_dict[class_id],
            'timestamp': timestamp,
            'image_url': image_url
        }

        # Save the event to Firestore with a unique ID
        print(event_data)
        db.collection('detection_events').document(unique_id).set(event_data)
        print(f"Saved event: {event_data} with ID {unique_id}")


def process_frame_with_detection(image: np.ndarray) -> np.ndarray:
    results = model(source=image, conf=0.25, verbose=False)[0]
    detections = sv.Detections.from_ultralytics(results)
    bounding_box_annotator = sv.BoundingBoxAnnotator()
    label_annotator = sv.LabelAnnotator()

    labels = [
        f"{category_dict[class_id]} {confidence:.2f}"
        for class_id, confidence in zip(detections.class_id, detections.confidence)
    ]

    # Log detection events and upload image to Firebase Storage
    for class_id, confidence in zip(detections.class_id, detections.confidence):
        # Pass image to save the annotated frame
        save_detection_event(class_id, confidence, image)

    annotated_image = bounding_box_annotator.annotate(
        image.copy(), detections=detections)
    annotated_image = label_annotator.annotate(
        annotated_image, detections=detections, labels=labels)
    return annotated_image


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.post("/stream")
async def stream(request: Request, background_tasks: BackgroundTasks):
    global frame, video_writer, video_writer_initialized

    contents = await request.body()
    nparr = np.frombuffer(contents, np.uint8)
    frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    annotated_frame = process_frame_with_detection(frame)
    frame = annotated_frame
    if frame is not None:
        # Initialize video writer if it's not yet initialized
        if not video_writer_initialized:
            fourcc = cv2.VideoWriter_fourcc(*'mp4v')  # Codec for mp4
            frame_height, frame_width = frame.shape[:2]
            video_writer = cv2.VideoWriter(
                output_filename, fourcc, 5.0, (frame_width, frame_height))
            video_writer_initialized = True

        # Write the current frame to the video file
        video_writer.write(frame)

    return {"message": "Frame received"}


def add_timestamp_to_frame(frame: np.ndarray) -> np.ndarray:
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    cv2.putText(frame, timestamp, (10, 30), cv2.FONT_HERSHEY_SIMPLEX,
                1, (255, 255, 255), 2, cv2.LINE_AA)
    return frame


def generate_video_stream():
    global frame
    while True:
        if frame is not None:
            frame_with_timestamp = add_timestamp_to_frame(frame.copy())
            _, encoded_frame = cv2.imencode('.jpg', frame_with_timestamp)
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + encoded_frame.tobytes() + b'\r\n')
        else:
            # Send a red frame if no frame is available
            red_frame = np.zeros((480, 640, 3), dtype=np.uint8)
            red_frame[:] = (0, 0, 255)  # Red color in BGR
            frame_with_timestamp = add_timestamp_to_frame(red_frame)
            _, encoded_frame = cv2.imencode('.jpg', frame_with_timestamp)
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + encoded_frame.tobytes() + b'\r\n')


@app.get("/video_feed")
def video_feed():
    return StreamingResponse(generate_video_stream(), media_type='multipart/x-mixed-replace; boundary=frame')


@app.get("/frame")
def get_frame():
    global frame
    if frame is not None:
        frame_with_timestamp = add_timestamp_to_frame(frame.copy())
        _, encoded_frame = cv2.imencode('.jpg', frame_with_timestamp)
        return StreamingResponse(io.BytesIO(encoded_frame.tobytes()), media_type='image/jpg')
    else:
        return HTMLResponse(content="<h1>No Frame Received</h1>", status_code=200)


@app.get("/view")
def view():
    html_content = """
    <html>
        <head>
            <title>Video Feed</title>
        </head>
        <body>
            <h1>Video Feed</h1>
            <img src="/video_feed" width="640" height="480" />
        </body>
    </html>
    """
    return HTMLResponse(content=html_content)


@app.on_event("shutdown")
def shutdown_event():
    global video_writer, output_filename
    if video_writer is not None:
        video_writer.release()
        # Create a new filename with timestamp
        timestamped_filename = f"{datetime.now().strftime('%Y%m%d_%H%M%S')}_{
            output_filename}"
        # Upload to Firebase Storage
        bucket = storage.bucket()
        blob = bucket.blob(os.path.basename(timestamped_filename))
        blob.upload_from_filename(output_filename)
        blob.make_public()
        print(f"Uploaded {output_filename} to Firebase Storage as {
              timestamped_filename}")
