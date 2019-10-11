FROM postgres:9

RUN apt-get update
RUN apt-get install -y pgloader emacs nano vim

USER postgres

WORKDIR /var/lib/postgresql

VOLUME [ "/var/lib/postgresql" ]

# PostgreSQL's port
EXPOSE 5432
