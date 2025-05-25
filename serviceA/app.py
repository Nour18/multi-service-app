from flask import Flask, jsonify, request

app = Flask(__name__)

# In-memory dictionary for storing users
users = {}

@app.route('/user', methods=['POST'])
def create_user():
    data = request.get_json()
    user_id = data.get('id')
    name = data.get('name')
    
    if not user_id or not name:
        return jsonify({"error": "ID and Name are required"}), 400

    users[user_id] = name
    return jsonify({"message": "User created"}), 201

@app.route('/user/<user_id>', methods=['GET'])
def get_user(user_id):
    if user_id not in users:
        return jsonify({"error": "User not found"}), 404
    
    return jsonify({"id": user_id, "name": users[user_id]}), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)

