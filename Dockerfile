FROM mariadb:latest

ENV MYSQL_DATABASE=InitIndikator
ENV MYSQL_USER=Basdat
ENV MYSQL_PASSWORD=Basdat
ENV MYSQL_ROOT_PASSWORD=Basdat

COPY ["Data Storing/src/tables.sql", "/docker-entrypoint-initdb.d/1-tables.sql"]
COPY ["Data Storing/export/IndikatorNegara.sql", "/docker-entrypoint-initdb.d/2-indikator-negara.sql"]

EXPOSE 3306