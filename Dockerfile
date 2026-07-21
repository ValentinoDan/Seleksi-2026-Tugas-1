FROM mariadb:latest

ENV MYSQL_DATABASE=Data_Storing
ENV MYSQL_USER=Basdat
ENV MYSQL_PASSWORD=Basdat
ENV MYSQL_ROOT_PASSWORD=Basdat

COPY ["Data Storing/export/IndikatorNegara.sql", "/docker-entrypoint-initdb.d/1-indikator-negara.sql"]
COPY ["Data Warehous/src/dim_fact.sql", "/docker-entrypoint-initdb.d/2-Dim-Fact.sql"]
COPY ["Data Warehous/src/insert.sql", "/docker-entrypoint-initdb.d/3-Insert.sql"]
COPY ["Data Warehous/src/event.sql", "/docker-entrypoint-initdb.d/4-Event.sql"]

EXPOSE 3306