#!/bin/sh
# entrypoint.sh
# Substitutes the __TMDB_V3_API_KEY__ placeholder in the built JS bundle
# with the value of TMDB_V3_API_KEY injected at runtime from a Kubernetes Secret.
# Falls back to an empty string if the env var is not set (degraded API mode).

set -e

KEY="${TMDB_V3_API_KEY:-}"

echo "==> Injecting TMDB API key into bundle..."

# Replace the placeholder in all JS files in-place
find /usr/share/nginx/html/assets -name "*.js" | while read -r file; do
  sed -i "s|__TMDB_V3_API_KEY__|${KEY}|g" "$file"
done

echo "==> Starting nginx..."
exec nginx -g "daemon off;"
