FROM nginx:alpine

COPY index.html /usr/share/nginx/html/
COPY styles.css /usr/share/nginx/html/
COPY app.js /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/conf.d/default.conf

LABEL version="1.0.3" \
      description="Todo App Frontend UI" \
      maintainer="Your Name <your.email@example.com>"

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
