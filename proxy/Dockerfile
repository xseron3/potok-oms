FROM nginx:alpine

RUN rm -f /etc/nginx/conf.d/default.conf

COPY proxy/vhost.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]