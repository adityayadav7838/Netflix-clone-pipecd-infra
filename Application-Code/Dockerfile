# ---------- Stage 1: Build ----------
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependency files first (leverage Docker cache)
COPY package*.json yarn.lock ./

# Install dependencies with frozen lockfile for consistency
RUN yarn install --frozen-lockfile

# Copy application source
COPY . .

# Build with a placeholder — the real key is injected at runtime via envsubst.
# VITE_APP_TMDB_V3_API_KEY is intentionally left as the literal placeholder string
# so entrypoint.sh can substitute it without needing the secret at build time.
ENV VITE_APP_TMDB_V3_API_KEY="__TMDB_V3_API_KEY__"
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"

# Build optimized production bundle
RUN yarn build && yarn cache clean


# ---------- Stage 2: NGINX serve ----------
FROM nginx:stable-alpine

# Install gettext for envsubst
RUN apk add --no-cache gettext

# Set working directory
WORKDIR /usr/share/nginx/html

# Clean default nginx content
RUN rm -rf ./*

# Copy built app from builder
COPY --from=builder /app/dist .

# Entrypoint: substitute __TMDB_V3_API_KEY__ placeholder with runtime env var,
# then start nginx. The secret is injected via a Kubernetes Secret, never baked
# into the image layer.
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose HTTP port
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]