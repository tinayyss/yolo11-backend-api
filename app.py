from flask import Flask, request, jsonify
from flask_cors import CORS
import datetime
import os

app = Flask(__name__)
CORS(app)

# In-memory database
users = []
detections = []

@app.route('/')
def home():
    return "YOLO11 Cloud API is Running!"

# --- AUTH: REGISTER ---
@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    if not data:
        return jsonify({"error": "No data"}), 400
    users.append(data)
    return jsonify({"message": "User registered successfully"}), 201

# --- CRUD: READ (GET) ---
@app.route('/detections', methods=['GET'])
def get_detections():
    return jsonify(detections[::-1]), 200

# --- CRUD: CREATE (POST) ---
@app.route('/detections', methods=['POST'])
def add_detection():
    data = request.get_json()
    new_entry = {
        "id": len(detections) + 1,
        "object": data.get('object', 'Unknown'),
        "confidence": data.get('confidence', '0%'),
        "time": datetime.datetime.now().strftime("%I:%M %p"),
        "zone": data.get('zone', 'Main Entrance'),
        "status": "Pending"
    }
    detections.append(new_entry)
    return jsonify(new_entry), 201

# --- CRUD: UPDATE (PUT) - Toggle Status ---
@app.route('/detections/<int:id>', methods=['PUT'])
def toggle_detection(id):
    data = request.get_json()
    for item in detections:
        if item['id'] == id:
            item['status'] = data.get('status', 'Verified')
            return jsonify(item), 200
    return jsonify({"error": "Not found"}), 404

# --- CRUD: DELETE (DELETE) ---
@app.route('/detections/<int:id>', methods=['DELETE'])
def delete_detection(id):
    global detections
    detections = [d for d in detections if d['id'] != id]
    return jsonify({"message": "Deleted"}), 200

if __name__ == '__main__':
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port)