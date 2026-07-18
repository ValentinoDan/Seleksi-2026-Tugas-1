FROM mariadb:latest

ENV MYSQL_DATABASE=IndikatorNegara
ENV MYSQL_USER=Basdat
ENV MYSQL_PASSWORD=Basdat
ENV MYSQL_ROOT_PASSWORD=Basdat

COPY ["Data Storing/src/tables.sql", "/docker-entrypoint-initdb.d/"]

EXPOSE 3306