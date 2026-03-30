# AWS Demo Guide (Frontend and Backend on Separate EC2)

This runbook deploys:
- Backend on one EC2 instance (`:8080`)
- Frontend on a second EC2 instance (`:80`)

## 1) Build and Push Images

Run from your local machine.

Backend image:
```powershell
Set-Location c:\Users\Chinmay\Desktop\digital-twin-ai-app\digital-twin-ai-backend
docker build -t <dockerhub-user>/digital-twin-ai-backend:latest .
docker push <dockerhub-user>/digital-twin-ai-backend:latest
```

Frontend image:
```powershell
Set-Location c:\Users\Chinmay\Desktop\digital-twin-ai-app\digital-twin-ai-frontend
docker build -t <dockerhub-user>/digital-twin-ai-frontend:latest .
docker push <dockerhub-user>/digital-twin-ai-frontend:latest
```

Update image names in:
- `docker-compose.backend.yml`
- `docker-compose.frontend.yml`

## 2) Create EC2 and Security Groups

Use Amazon Linux 2023 for both EC2 instances.

Security group for frontend EC2:
- Inbound `80` from `0.0.0.0/0`
- Inbound `22` from your IP

Security group for backend EC2:
- Inbound `8080` from **frontend security group only**
- Inbound `22` from your IP

## 3) Prepare Backend EC2

SSH into backend EC2 and install Docker:
```bash
sudo dnf update -y
sudo dnf install -y docker docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user
newgrp docker
```

Create deployment folder and files:
```bash
mkdir -p ~/digital-twin-backend && cd ~/digital-twin-backend
```

Copy these files from local machine to backend EC2:
- `docker-compose.backend.yml`
- `.env.backend.example` (rename to `.env`)

Edit `.env` on backend EC2:
- Set `MONGODB_URI`
- Set `JWT_SECRET`
- Set `GEMINI_API_KEY`
- Set `SMTP_USERNAME`
- Set `SMTP_PASSWORD`
- Set `CORS_ALLOWED_ORIGINS=http://<frontend-public-ip-or-domain>`

Run backend:
```bash
docker compose -f docker-compose.backend.yml --env-file .env up -d
docker compose -f docker-compose.backend.yml ps
docker logs --tail 100 backend
```

## 4) Prepare Frontend EC2

SSH into frontend EC2 and install Docker:
```bash
sudo dnf update -y
sudo dnf install -y docker docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker ec2-user
newgrp docker
```

Create deployment folder and files:
```bash
mkdir -p ~/digital-twin-frontend && cd ~/digital-twin-frontend
```

Copy these files from local machine to frontend EC2:
- `docker-compose.frontend.yml`
- `.env.frontend.example` (rename to `.env`)

Edit `.env` on frontend EC2:
- Set `BACKEND_UPSTREAM=<backend-private-ip>:8080`

Run frontend:
```bash
docker compose -f docker-compose.frontend.yml --env-file .env up -d
docker compose -f docker-compose.frontend.yml ps
docker logs --tail 100 frontend
```

## 5) Validate

From your laptop browser:
- `http://<frontend-public-ip>`

From frontend EC2:
```bash
curl -i http://<backend-private-ip>:8080/actuator/health
```

## 6) Common Fixes

- If login/API fails, verify `CORS_ALLOWED_ORIGINS` exactly matches frontend URL.
- If chat socket fails, verify backend `8080` is allowed from frontend security group.
- If frontend starts but API fails, verify `.env` has correct `BACKEND_UPSTREAM`.
