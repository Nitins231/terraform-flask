const express = require('express');
const path = require('path');
const bodyParser = require('body-parser');
const axios = require('axios');

const app = express();
const port = 3000;

// Middleware
app.use(express.static('public'));
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

// Serve the form
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'Templates', 'index.html'));
});

// Handle form submit and forward to Flask
app.post('/submit', async (req, res) => {
  try {
    const response = await axios.post('http://backend-service:5000/api/submit', req.body);
    res.send(`<h2>${response.data.message}</h2>`);
  } catch (error) {
    console.error(error.message);
    res.status(500).send('Error forwarding data to Python backend');
  }
});

app.listen(port, () => {
  console.log(`Frontend running at http://localhost:${port}`);
});
