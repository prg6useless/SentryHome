from typing import Union
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


def process_frame_with_detection(image: np.ndarray) -> np.ndarray:
    results = model(source=image, conf=0.25, verbose=False)[0]
    detections = sv.Detections.from_ultralytics(results)
    box_annotator = sv.BoxAnnotator()

    labels = [
        f"{category_dict[class_id]} {confidence:.2f}"
        for class_id, confidence in zip(detections.class_id, detections.confidence)
    ]
    annotated_image = box_annotator.annotate(
        image.copy(), detections=detections, labels=labels
    )
    return annotated_image


@app.get("/")
def read_root():
    return {"Hello": "World"}

# async def process_frame(contents: bytes):
#     global frame
#     nparr = np.frombuffer(contents, np.uint8)
#     decoded_frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
#     frame = decoded_frame


@app.post("/stream")
<< << << < HEAD


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
                output_filename, fourcc, 15.0, (frame_width, frame_height))
            video_writer_initialized = True

        # Write the current frame to the video file
        video_writer.write(frame)

== == == =


async def stream(request: Request, background_tasks: BackgroundTasks):
    global frame
    contents = await request.body()
    nparr = np.frombuffer(contents, np.uint8)
    decoded_frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    annotated_frame = process_frame_with_detection(decoded_frame)
    frame = annotated_frame
>>>>>> > 74a7f7a318596ca34bf4c351af92edf2cd0a68b3
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
    global video_writer
    if video_writer is not None:
        video_writer.release()

# Run the FastAPI app with the command `uvicorn yourfilename:app --reload`
