FROM postgres:16-alpine

WORKDIR /init

COPY db-init/schema.sql /init/schema.sql
COPY db-init/seed.sql   /init/seed.sql
COPY db-init/init.sh    /init/init.sh

RUN chmod +x /init/init.sh

ENTRYPOINT []
CMD ["/init/init.sh"]