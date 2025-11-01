# 🏗️ Stage 1: Build Flutter Web App
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
COPY fancy_todo/ ./
RUN flutter pub get && flutter build web --release

# 🖼️ Stage 2: Serve with Nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html

# Optional: Replace default Nginx config (for SPA routing or env injection)
# COPY nginx.conf /etc/nginx/nginx.conf

# ✅ Add this line to copy the .env file
COPY fancy_todo/assets/.env /usr/share/nginx/html/assets/.env

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]