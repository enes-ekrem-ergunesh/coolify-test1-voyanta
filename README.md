# Voyanta Travel Agency - Dockerized Deployment

This repository has been fully dockerized to serve this static site using an optimized, high-performance, and secure **Nginx** server. It exposes a standard HTTP port (`8080`) which is ideal for routing behind a reverse proxy (such as Nginx, Caddy, or Traefik).

---

## 🛠️ Dockerized Architecture

The containerized setup includes:
1. **`Dockerfile`**: Packages the static files on top of the ultra-lightweight, cached `nginx:1.26.3-alpine` base image.
2. **`default.conf`**: Custom Nginx server block optimized for static file delivery. Features:
   * **Gzip Compression**: Automatically compresses CSS, JavaScript, and HTML on the fly.
   * **Security Headers**: Includes robust protection (`X-Frame-Options`, `X-Content-Type-Options`, and `Referrer-Policy`).
   * **Health Endpoint**: Exposes `/health` for container and platform probes.
   * **Aggressive Static Caching**: Sets a `1y` cache-control header for styling assets, scripts, and media files to boost page performance.
   * **Automatic Directory Indexing**: Safely routes both standard paths and subdirectories (like `/admin/`).
3. **`docker-compose.yml`**: Simplifies orchestration and adds a Docker healthcheck against `/health`.
4. **`.dockerignore`**: Excludes development assets like `.git`, `Dockerfile`, and composition configurations to keep the production image tiny and secure.

---

## 🚀 How to Run

### Option 1: Using Docker Compose (Recommended)

To start the website in the background:
```bash
docker compose up -d
```

To view logs:
```bash
docker compose logs -f
```

To stop the container:
```bash
docker compose down
```

### Option 2: Using standard Docker CLI

If you prefer building and running manually:

1. **Build the image**:
   ```bash
   docker build -t voyanta-web .
   ```

2. **Run the container** (maps port `8080` of your host to port `80` inside the container):
   ```bash
   docker run -d --name voyanta-web -p 8080:80 --restart unless-stopped voyanta-web
   ```

3. **Stop the container**:
   ```bash
   docker stop voyanta-web && docker rm voyanta-web
   ```

---

## 🔄 Reverse Proxy Setup

Once the container is running and exposing port `8080` on localhost (`127.0.0.1:8080`), you can set up a reverse proxy on your host server.

Below are three standard configurations for popular web servers:

### 1. Nginx Host Configuration
If you run Nginx on your main server system, add this to your site configuration block (e.g., `/etc/nginx/sites-available/voyanta.conf`):

```nginx
server {
    listen 80;
    server_name yourdomain.com; # Replace with your domain or IP

    # Redirect all HTTP traffic to HTTPS (Optional but Recommended)
    # return 301 https://$host$request_uri;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket support (if ever needed)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### 2. Caddyfile Configuration
If you use Caddy (which automatically provisions SSL certificates via Let's Encrypt), add this to your `/etc/caddy/Caddyfile`:

```caddy
yourdomain.com {
    reverse_proxy 127.0.0.1:8080
}
```

### 3. Apache Configuration
If you use Apache (`httpd`), ensure `mod_proxy` and `mod_proxy_http` are enabled, and add the following to your VirtualHost file:

```apache
<VirtualHost *:80>
    ServerName yourdomain.com

    ProxyPreserveHost On
    ProxyPass / http://127.0.0.1:8080/
    ProxyPassReverse / http://127.0.0.1:8080/

    ErrorLog ${APACHE_LOG_DIR}/voyanta-error.log
    CustomLog ${APACHE_LOG_DIR}/voyanta-access.log combined
</VirtualHost>
```

---

## 🔍 Verification

Verify that the site is active by sending a curl request locally:
```bash
curl -I http://localhost:8080
```
This should return `HTTP/1.1 200 OK` with server type `nginx/1.26.3`.

Verify the health endpoint:
```bash
curl -fsS http://localhost:8080/health
```
This should return `ok`.
