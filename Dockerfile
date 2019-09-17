FROM postgres:9

RUN apt-get update
RUN apt-get install -y pgloader

USER postgres

VOLUME [ "/var/lib/postgresql/data" ]
