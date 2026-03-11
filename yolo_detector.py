import cv2
import requests
from ultralytics import YOLO
import time

model = YOLO("yolo11n.pt")
API_URL = "https://your-yolo-api.onrender.com/detections"

cap = cv2.VideoCapture(0)
last_time = 0

while cap.isOpened():
    res, frame = cap.read()
    if not res: break

    results = model(frame, conf=0.5, verbose=False)
    for r in results:
        for box in r.boxes:
            if model.names[int(box.cls[0])] == "person":
                if time.time() - last_time > 5:
                    payload = {"object": "Pedestrian", "confidence": f"{box.conf[0]:.2%}", "zone": "Cam 01"}
                    try:
                        # CREATE ACTION
                        requests.post(API_URL, json=payload, timeout=2)
                        print("Data Sent to Render Cloud!")
                        last_time = time.time()
                    except: print("Backend Sleeping/Offline")

    cv2.imshow("YOLO11 Thesis Feed", results[0].plot())
    if cv2.waitKey(1) & 0xFF == ord("q"): break

cap.release()
cv2.destroyAllWindows()