FROM postgres:9

RUN apt-get update
RUN apt-get install -y pgloader emacs nano vim

# The postgres user's home is *not* in /home/postgres.
COPY .psqlrc /var/lib/postgresql
RUN chown postgres /var/lib/postgresql/.psqlrc

USER postgres

VOLUME [ "/var/lib/postgresql/data" ]
