#!/bin/bash

# Update system
sudo apt update -y

# Install Python & Flask dependencies
sudo apt install -y python3 python3-pip
pip3 install flask pymongo python-dotenv flask-cors

# Install Node.js & Express
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
npm install -g express

# Create app directory
mkdir -p /opt/apps/Templates
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

# Write Express frontend (app.js)
cat <<EOF > app.js
const express = require('express');
const path = require('path');
const bodyParser = require('body-parser');
const axios = require('axios');

const app = express();
const port = 3000;

app.use(express.static('public'));
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'Templates', 'index.html'));
});

app.post('/submit', async (req, res) => {
  try {
    const response = await axios.post('http://localhost:5000/api/submit', req.body);
    res.send(\`<h2>\${response.data.message}</h2>\`);
  } catch (error) {
    console.error(error.message);
    res.status(500).send('Error forwarding data to Python backend');
  }
});

app.listen(port, () => {
  console.log(\`Frontend running at http://0.0.0.0:\${port}\`);
});
EOF

# Write HTML form page (index.html)
cat <<EOF > Templates/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Sign Up</title>
  <style>
    body {
      margin: 0;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background: linear-gradient(to right, #74ebd5, #acb6e5);
      height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .container {
      background-color: white;
      padding: 40px 30px;
      border-radius: 12px;
      box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
      width: 100%;
      max-width: 400px;
    }
    h1 {
      text-align: center;
      margin-bottom: 30px;
      color: #333;
    }
    .form-group {
      margin-bottom: 20px;
    }
    label {
      display: block;
      font-weight: 600;
      margin-bottom: 6px;
      color: #555;
    }
    input {
      width: 100%;
      padding: 10px;
      border-radius: 6px;
      border: 1px solid #ccc;
      box-sizing: border-box;
    }
    button {
      width: 100%;
      padding: 12px;
      background-color: #007bff;
      color: white;
      border: none;
      border-radius: 6px;
      font-size: 16px;
      font-weight: 600;
      cursor: pointer;
      transition: background-color 0.3s;
    }
    button:hover {
      background-color: #0056b3;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>Sign Up</h1>
    <form action="/submit" method="POST">
      <div class="form-group">
        <label for="name">Full Name</label>
        <input type="text" id="name" name="name" placeholder="Enter your name" required />
      </div>
      <div class="form-group">
        <label for="email">Email Address</label>
        <input type="email" id="email" name="email" placeholder="Enter your email" required />
      </div>
      <div class="form-group">
        <label for="password">Password</label>
        <input type="password" id="password" name="password" placeholder="Enter your password" required />
      </div>
      <button type="submit">Sign Up</button>
    </form>
  </div>
</body>
</html>
EOF

# Export MongoDB URI (replace with real credentials)
echo 'MONGO_URI="mongodb+srv://ns465626:l6xVApkXWLt3OJyQ@dango.xedzjnc.mongodb.net/?retryWrites=true&w=majority&appName=Dango"' > /opt/apps/.env


# Start both apps
nohup python3 /opt/apps/app.py > /opt/apps/flask.log 2>&1 &
nohup node /opt/apps/app.js > /opt/apps/express.log 2>&1 &
