# Projet Fil Rouge - Module 2 - Docker

## Description

Ce projet consiste à dockeriser deux applications distinctes - un backend Flask et un frontend Web - et à les faire communiquer entre elles. Les participants apprendront à créer des Dockerfiles appropriés, à construire des images, à configurer des variables d'environnement et à exposer des ports pour permettre la communication entre conteneurs.

## Objectifs

1. Créer un Dockerfile pour l'application backend Flask
2. Créer un Dockerfile pour l'application frontend
3. Construire les images Docker des deux applications
4. Exécuter les conteneurs avec les bons mappages de ports
5. Configurer la communication entre frontend et backend
6. Vérifier le bon fonctionnement de l'ensemble

## Fichiers fournis

- `backend/app.py` : Application Flask qui expose des endpoints `/health`, `/auth`, et `/api`

```python
# Créer un dossier backend à la racine

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
```

- `backend/requirements.txt` : Dépendances Python nécessaires

```bash
Flask==2.1.1
Werkzeug==2.1.2
Flask-Cors==3.0.10
PyJWT==2.3.0
```

- `frontend/dist/index.html` : Interface utilisateur qui se connecte au backend

```html
<!-- Créer un dossier frontend à la racine et un dossier -->
<!-- dist dans le dossier frontend -->

<!DOCTYPE html>
<html>
<head>
    <title>Frontend</title>
</head>
<body>
    <h1>Frontend App</h1>
    <p>Data from backend will appear below:</p>
    <script>
        fetch(`__BACKEND_URL__/health`)
            .then(response => response.json())
            .then(data => {
                document.body.innerHTML += `<pre>${JSON.stringify(data, null, 2)}</pre>`;
            });
    </script>
</body>
</html>
```

## Instructions

### Backend

1. Créez un Dockerfile dans le dossier `backend/` qui:
    - Utilise une image Python appropriée
    - Installe les dépendances du fichier requirements.txt
    - Expose le port 5000
    - Configure l'application pour écouter sur toutes les interfaces
2. Construisez l'image avec le tag `backend`
3. Lancez le conteneur en exposant le port 1234 sur l'hôte pour le port 5000 du conteneur

### Frontend

1. Créez un Dockerfile dans le dossier `frontend/` qui:
    - Utilise une image NGINX
    - Copie les fichiers du dossier `dist/` dans le répertoire approprié pour NGINX
    - **Utilise ARG et ENV** pour permettre le remplacement de la variable `__BACKEND_URL__` par l'URL réelle du backend
    - Expose le port 80
2. Construisez l'image avec le tag `frontend`
3. Lancez le conteneur en exposant le port 9999 sur l'hôte pour le port 80 du conteneur

## Indices

1. **Pour le backend:**
    - Assurez-vous que dans [app.py](http://app.py/), l'application écoute sur toutes les interfaces via `host="0.0.0.0"`
    - Le build devrait se faire avec: `docker build -t backend -f backend/Dockerfile . --no-cache`
    - Pour exécuter le conteneur: `docker run -p 1234:5000 -d backend`
    - Testez votre backend avec: `http://localhost:1234/health`
2. **Pour le frontend:**
    - Créez un script d'entrée ([entrypoint.sh](http://entrypoint.sh/)) qui remplace dynamiquement `__BACKEND_URL__` dans index.html
    - Utilisez ARG pour définir l'URL du backend au moment du build
    - Utilisez ENV pour passer l'URL au moment de l'exécution
    - Le build devrait se faire avec: `docker build -t frontend -f frontend/Dockerfile . --no-cache`
    - Pour exécuter le conteneur: `docker run -p 9999:80 -e BACKEND_URL="<http://localhost:1234>" -d frontend`
    - Testez votre frontend avec: `http://localhost:9999`
3. **Dépannage courant:**
    - Attention à l'ordre des options dans la commande docker run: les options comme -p doivent apparaître avant le nom de l'image
    - Vérifiez les logs des conteneurs si quelque chose ne fonctionne pas: `docker logs <container_id>`
    - Assurez-vous que le backend est accessible depuis l'extérieur du conteneur

## Validation

Votre solution sera validée lorsque:

1. Le conteneur backend est accessible sur le port 1234
2. Le conteneur frontend est accessible sur le port 9999
3. Le frontend affiche les informations reçues du backend
4. L'endpoint `/health` renvoie `{"status": "healthy"}`