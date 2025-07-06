from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
import os
import pymongo

# Load environment variables
load_dotenv()

# Connect to MongoDB
MONGO_URI = os.getenv('MONGO_URI')
client = pymongo.MongoClient(MONGO_URI)
db = client['test']  # or your actual DB name
collection = db['app_training']

# Create Flask app
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

    print(f"Received: {name}, {email}, {password}")

    # Insert into MongoDB
    document = {
        'name': name,
        'email': email,
        'password': password  # consider hashing passwords in real apps!
    }

    try:
        result = collection.insert_one(document)
        print(f"Inserted ID: {result.inserted_id}")
        return jsonify({'message': f'Thank you for signing up, {name}!', 'id': str(result.inserted_id)})

    except Exception as e:
        print(f"MongoDB insert error: {e}")
        return jsonify({'message': 'Error saving to database'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
