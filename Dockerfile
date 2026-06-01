# Use the lightweight official Nginx Alpine image
FROM nginx:1.26.3-alpine


# Install curl for a deterministic container health probe
RUN apk add --no-cache curl


# Copy the custom Nginx configuration
COPY default.conf /etc/nginx/conf.d/default.conf

# Copy the static website files into the default Nginx public directory
COPY . /usr/share/nginx/html

# Expose port 80 to the Docker network
EXPOSE 80

# Health check for platforms that read Dockerfile HEALTHCHECK instead of compose
HEALTHCHECK --interval=15s --timeout=5s --start-period=20s --retries=5 \
	CMD curl -fsS http://127.0.0.1/health >/dev/null || exit 1

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
