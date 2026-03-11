from flask import Flask, request, jsonify
from flask_cors import CORS
import datetime
import os

app = Flask(__name__)
CORS(app)

# Databases (Temporary/In-Memory)
users = []
detections = []

@app.route('/')
def home():
    return "YOLO11 Cloud API is Running!"

# --- AUTH LOGIC ---
@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    if any(u['username'] == data['username'] for u in users):
        return jsonify({"message": "Username exists"}), 400
    users.append(data)
    return jsonify({"message": "User created"}), 201

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    user = next((u for u in users if u['username'] == data['username'] and u['password'] == data['password']), None)
    if user:
        return jsonify({"message": "Success", "name": user['name']}), 200
    return jsonify({"message": "Failed"}), 401

# --- CRUD LOGIC ---
@app.route('/detections', methods=['GET', 'POST'])
def handle_detections():
    if request.method == 'POST':
        data = request.get_json()
        new_log = {
            "id": len(detections) + 1,
            "object": data.get('object', 'Unknown'),
            "confidence": data.get('confidence', '0%'),
            "time": datetime.datetime.now().strftime("%I:%M %p"),
            "status": "Active"
        }
        detections.append(new_log)
        return jsonify(new_log), 201
    return jsonify(detections[::-1]), 200

@app.route('/detections/<int:id>', methods=['DELETE'])
def delete_detection(id):
    global detections
    detections = [log for log in detections if log['id'] != id]
    return jsonify({"message": "Deleted"}), 200

if __name__ == '__main__':
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port)
