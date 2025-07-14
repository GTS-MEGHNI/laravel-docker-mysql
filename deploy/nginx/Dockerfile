FROM nginx:stable-alpine

COPY default.conf /etc/nginx/conf.d/default.conf

# Copy the public folder from your existing Laravel image
COPY --from=laravel-image:latest /var/www/html/public /var/www/html/public

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
