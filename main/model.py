from flask import Flask, request, jsonify
import anthropic
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi

app = Flask(__name__)

# === ANTHROPIC ===
claude_client = anthropic.Anthropic()

@app.route('/ask', methods=['GET'])
def ask():
    try:
        user_prompt = "Give me a healthy habit. Give a very short response. Very very short. Give only the habits separated by ; so i can parse them easily"

        message = claude_client.messages.create(
            model="claude-3-7-sonnet-20250219",
            max_tokens=1000,
            temperature=1,
            system="You are a doctor and a psychologist. Give short responses.",
            messages=[{"role": "user", "content": [{"type": "text", "text": user_prompt}]}]
        )
        
        text_response = getattr(message, 'completion', None) or getattr(message, 'content', None)
        return jsonify({"response": str(text_response)})
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/plan', methods=['GET'])
def plan():
    try:
        user_prompt = "Give me a healthy plan. 20 easy habits to become a better person. Give only the habits separated by ; so i can parse them easily"
        
        message = claude_client.messages.create(
            model="claude-3-7-sonnet-20250219",
            max_tokens=1000,
            temperature=1,
            system="You are a doctor and a psychologist. Give short responses.",
            messages=[{"role": "user", "content": [{"type": "text", "text": user_prompt}]}]
        )
        
        text_response = getattr(message, 'completion', None) or getattr(message, 'content', None)
        return jsonify({"response": str(text_response)})
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# === MONGO DB ===

uri = "mongodb+srv://admin:admin@cluster0.nysuq81.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
mongo_client = MongoClient(uri, server_api=ServerApi('1'))

# Verifică conexiunea
try:
    mongo_client.admin.command('ping')
    print("Pinged your deployment. You successfully connected to MongoDB!")
except Exception as e:
    print(e)

db = mongo_client["flutter_app"]
users_collection = db["users"]


@app.route('/create_user', methods=['POST'])
def create_user():
    data = request.json
    username = data.get("username")

    if not username:
        return jsonify({"error": "Missing username"}), 400

    existing = users_collection.find_one({"username": username})
    if existing:
        return jsonify({"message": "User already exists"}), 200

    users_collection.insert_one({"username": username, "xp": 0})
    return jsonify({"message": f"User {username} created!"}), 201


@app.route('/get_xp/<username>', methods=['GET'])
def get_xp(username):
    user = users_collection.find_one({"username": username})
    if not user:
        return jsonify({"error": "User not found"}), 404
    return jsonify({"xp": user.get("xp", 0)})


@app.route('/increment_xp', methods=['POST'])
def increment_xp():
    data = request.json
    username = data.get("username")
    amount = data.get("amount", 1)

    result = users_collection.update_one({"username": username}, {"$inc": {"xp": amount}})
    if result.matched_count == 0:
        return jsonify({"error": "User not found"}), 404

    return jsonify({"message": f"Added {amount} XP to {username}"})

@app.route('/leaderboard', methods=['GET'])
def leaderboard():
    try:
        collection = mongo_client["flutter_app"]["users"]
        users = list(collection.find({}, {"_id": 0, "username": 1, "xp": 1}))
        users.sort(key=lambda u: u.get("xp", 0), reverse=True)
        return jsonify(users)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5001)
