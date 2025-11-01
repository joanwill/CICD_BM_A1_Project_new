# Build Flutter web
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
COPY fancy_todo/ ./
RUN flutter pub get && flutter build web --release

# Serve with nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
