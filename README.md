# Correction - Module 2 - Docker

Retrouver le code source pour la correction du module Docker sur GitHub sur la branche “docker” : [https://github.com/simonbrienne/formation-projet/tree/docker](https://github.com/simonbrienne/formation-projet/tree/docker)

**Build de l’image frontend :**

```bash
docker build -t frontend -f frontend/Dockerfile . --no-cache
```

**Build de l’image backend :**

```bash
docker build -t backend -f backend/Dockerfile . --no-cache
```

**Run de l’image backend sur le port 1234 :**

```bash
docker run -p 1234:5000 -d backend
```

**Run de l’image frontend sur le port 9999 :** 

```bash
docker run -p 9999:80 -e BACKEND_URL="http://127.0.0.1:1234" -d frontend
```

**Rendez-vous sur chrome :** 

Test du backend : [http://127.0.0.1:1234/health](http://127.0.0.1:1234/health)

Test du frontend : [http://127.0.0.1:9999](http://127.0.0.1:9999)