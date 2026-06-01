# Use the lightweight official Nginx Alpine image
FROM nginx:1.26.3-alpine


# Copy the custom Nginx configuration
COPY default.conf /etc/nginx/conf.d/default.conf

# Copy the static website files into the default Nginx public directory
COPY . /usr/share/nginx/html

# Expose port 80 to the Docker network
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
