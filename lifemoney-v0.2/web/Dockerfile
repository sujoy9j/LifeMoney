FROM nginx:1.27-alpine
COPY . /usr/share/nginx/html
RUN printf 'server {\n  listen 8080;\n  server_name _;\n  root /usr/share/nginx/html;\n  index index.html;\n  location / { try_files $uri $uri/ /index.html; }\n  location = /health { add_header Content-Type application/json; return 200 '{\"status\":\"ok\",\"service\":\"lifemoney-web\"}'; }\n}\n' > /etc/nginx/conf.d/default.conf
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
