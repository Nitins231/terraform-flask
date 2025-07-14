#!/bin/bash

# Update system
sudo apt update -y

# Install Node.js & Express dependencies
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
npm install -g express

# Create app directory
mkdir -p /opt/apps/Templates
cd /opt/apps

# Write Express frontend (app.js)
cat <<'EOF' > app.js
const express = require('express');
const path = require('path');
const bodyParser = require('body-parser');
const axios = require('axios');

const app = express();
const port = 3000;

// Serve static files from Templates directory
app.use(express.static(path.join(__dirname, 'Templates')));
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'Templates', 'index.html'));
});

app.post('/submit', async (req, res) => {
  try {
    const response = await axios.post('http://10.0.1.153:5000/api/submit', req.body);
    res.send(`<h2>` + response.data.message + `</h2>`);

  } catch (error) {
    console.error(error.message);
    res.status(500).send('Error forwarding data to Python backend');
  }
});

app.listen(port, () => {
  console.log("Frontend running at http://0.0.0.0:3000");
});
EOF


# Write HTML form page
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

# Start Express app
nohup node /opt/apps/app.js > /opt/apps/express.log 2>&1 &
