#!/bin/bash

# Update system
sudo apt update -y

# Install Python and dependencies
sudo apt install -y python3 python3-pip
pip3 install flask pymongo python-dotenv flask-cors

# Create app directory
mkdir -p /opt/apps
cd /opt/apps

# Write Flask backend (app.py)
cat <<EOF > app.py
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
import os
import pymongo

load_dotenv()
MONGO_URI = os.getenv('MONGO_URI')
client = pymongo.MongoClient(MONGO_URI)
db = client['test']
collection = db['app_training']

app = Flask(__name__)
CORS(app)

@app.route('/api/submit', methods=['POST'])
def handle_form():
    data = request.get_json()
    if not data:
        return jsonify({'message': 'No data received'}), 400
    name = data.get('name')
    email = data.get('email')
    password = data.get('password')
    document = {'name': name, 'email': email, 'password': password}
    try:
        result = collection.insert_one(document)
        return jsonify({'message': f'Thank you for signing up, {name}!', 'id': str(result.inserted_id)})
    except Exception as e:
        return jsonify({'message': 'Error saving to database'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# Export MongoDB URI (replace with your actual credentials if needed)
echo 'export MONGO_URI="mongodb+srv://ns465626:l6xVApkXWLt3OJyQ@dango.xedzjnc.mongodb.net/?retryWrites=true&w=majority&appName=Dango"' > /etc/profile.d/mongo.sh
source /etc/profile

# Start Flask app
nohup python3 /opt/apps/app.py > /opt/apps/flask.log 2>&1 &
