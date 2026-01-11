FROM alpine:latest

RUN apk add --no-cache nginx
RUN mkdir -p /var/www/html /run/nginx
RUN rm -rf /etc/nginx/conf.d/*
COPY conf.d/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
