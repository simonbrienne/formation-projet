import os
import jwt
import datetime
from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app, resources={r"/health": {"origins": "*"}})

# Chemin de santé pour vérifier si le serveur est en cours d'exécution
@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy"}), 200

# Chemin d'authentification pour générer un token
@app.route("/auth", methods=["POST"])
def auth():
    payload = {
        "exp": datetime.datetime.utcnow() + datetime.timedelta(minutes=30),
        "iat": datetime.datetime.utcnow(),
        "sub": "user_123"
    }
    secret_key = os.getenv("SECRET_KEY", "VOTRE_CLE_SECRETE")
    token = jwt.encode(payload, secret_key, algorithm="HS256")
    return jsonify({"token": token})

# Chemin protégé qui nécessite un token
@app.route("/api", methods=["GET"])
def get_data():
    auth_header = request.headers.get("Authorization", None)
    if not auth_header:
        return jsonify({"error": "Token manquant"}), 401
    try:
        _, token = auth_header.split()
        secret_key = os.getenv("SECRET_KEY", "VOTRE_CLE_SECRETE")
        decoded = jwt.decode(token, secret_key, algorithms=["HS256"])
        return jsonify({
            "message": "Hello from Backend with token!",
            "user": decoded["sub"]
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 401

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)