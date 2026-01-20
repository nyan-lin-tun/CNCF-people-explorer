# Multi-stage Dockerfile for CNCF People Explorer
# Supports 3 variants: standalone, frontend, example

# Build stage
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Accept build argument for variant mode
ARG MODE=standalone

# Copy package files
COPY package*.json ./

# Install dependencies (including devDependencies needed for build)
RUN npm ci

# Copy source code
COPY . .

# Build based on MODE
RUN if [ "$MODE" = "frontend" ]; then \
      echo "Building frontend variant (connects to backend API)"; \
      npm run build; \
    elif [ "$MODE" = "example" ]; then \
      echo "Building example variant (with sample data)"; \
      VITE_API_URL=/data/example-data.json npm run build; \
    else \
      echo "Building standalone variant (uses CNCF API)"; \
      npm run build; \
    fi

# Production stage
FROM nginx:alpine

# Install curl for healthcheck
RUN apk add --no-cache curl

# Accept MODE argument again for production stage
ARG MODE=standalone

# Copy custom nginx config
RUN cat > /etc/nginx/conf.d/default.conf <<'EOF'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# Copy built files from builder
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy public directory (contains example data)
COPY --from=builder /app/public /tmp/public

# Setup example data for example variant
RUN if [ "$MODE" = "example" ]; then \
      mkdir -p /usr/share/nginx/html/data && \
      if [ -f /tmp/public/data/example-data.json ]; then \
        cp /tmp/public/data/example-data.json /usr/share/nginx/html/data/; \
      fi \
    fi && \
    rm -rf /tmp/public

# Create entrypoint script for frontend variant
RUN if [ "$MODE" = "frontend" ]; then \
      echo '#!/bin/sh' > /docker-entrypoint.sh && \
      echo 'set -e' >> /docker-entrypoint.sh && \
      echo 'if [ -n "$VITE_API_URL" ]; then' >> /docker-entrypoint.sh && \
      echo '  echo "Configuring frontend to use API: $VITE_API_URL"' >> /docker-entrypoint.sh && \
      echo '  find /usr/share/nginx/html -type f -name "*.js" -exec sed -i "s|https://raw.githubusercontent.com/cncf/people/refs/heads/main/people.json|$VITE_API_URL|g" {} \\;' >> /docker-entrypoint.sh && \
      echo 'fi' >> /docker-entrypoint.sh && \
      echo 'exec nginx -g "daemon off;"' >> /docker-entrypoint.sh && \
      chmod +x /docker-entrypoint.sh; \
    fi

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# Expose port
EXPOSE 80

# Set default command based on variant
CMD [ "/bin/sh", "-c", "if [ -f /docker-entrypoint.sh ]; then /docker-entrypoint.sh; else nginx -g 'daemon off;'; fi" ]

# Labels
LABEL maintainer="nyan-lin-tun"
LABEL description="CNCF People Explorer - Cloud Native Community Directory"
LABEL version="1.0"
LABEL variant="${MODE}"
