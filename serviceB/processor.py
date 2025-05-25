import os
from flask import Flask, jsonify, request
import requests

app = Flask(__name__)


SERVICE_A_URL = os.environ.get('SERVICE_A_URL', 'http://localhost:5000/user')

@app.route('/process/<user_id>', methods=['GET'])
def process_user(user_id):
    try:
        # Contact Service A inside Docker network
        response = requests.get(f'{SERVICE_A_URL}/{user_id}')
        if response.status_code != 200:
            return jsonify({'error': 'User not found'}), 404

        data = response.json()
        processed_data = {
            'original': data,
            'processed_name': data['name'].upper()
        }
        return jsonify(processed_data)

    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Run on 0.0.0.0 to allow Docker network access
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
