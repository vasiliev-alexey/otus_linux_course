FROM nginx:alpine

COPY ./.nginx/nginx.conf /etc/nginx/nginx.conf

RUN rm -rf /usr/share/nginx/html/*

COPY  ./ui /usr/share/nginx/html

ENTRYPOINT ["nginx", "-g", "daemon off;"]