from typing import Union
from fastapi import FastAPI, Request
from fastapi.responses import StreamingResponse, HTMLResponse
import io
import cv2
import numpy as np
from starlette.middleware.cors import CORSMiddleware
import asyncio
from datetime import datetime

app = FastAPI()

frame = None

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.post("/stream")
async def stream(request: Request):
    global frame
    contents = await request.body()
    nparr = np.frombuffer(contents, np.uint8)
    frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
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
    frame_with_timestamp = add_timestamp_to_frame(frame.copy())
    _, encoded_frame = cv2.imencode('.jpg', frame_with_timestamp)
    return StreamingResponse(io.BytesIO(encoded_frame.tobytes()), media_type='image/jpg')


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
