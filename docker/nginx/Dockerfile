FROM alpine:latest

RUN apk add --no-cache nginx
RUN mkdir -p /var/www/html /run/nginx

# Clean default configs (http.d has default.conf from apk)
RUN rm -rf /etc/nginx/http.d/*
# Clean conf.d just in case
RUN rm -rf /etc/nginx/conf.d/*

# Copy our config to http.d (Correct for Alpine)
COPY conf.d/default.conf /etc/nginx/http.d/default.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]