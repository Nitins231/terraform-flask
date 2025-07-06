🐳 Fullstack Signup App – Flask + Express + MongoDB

This project is a fullstack application with:

- 🔥 **Frontend**: Node.js with Express (serves a styled `index.html` form)
- 🧠 **Backend**: Python Flask (receives form data via POST, stores in MongoDB)
- 🐬 **Database**: MongoDB (can be local or Atlas cloud)
- 📦 **Dockerized** with `docker-compose` for easy deployment

---

## 🚀 Project Structure

project-root/
├── backend/ # Python Flask API
│ ├── app.py
│ ├── requirements.txt
│ ├── .env
│ └── Dockerfile
│
├── frontend/ # Node.js + Express frontend
│ ├── app.js
│ ├── index.html
│ ├── package.json
│ └── Dockerfile
│
├── docker-compose.yml # Orchestrates both containers
└── .gitignore

