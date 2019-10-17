FROM postgres:9

RUN apt-get update
# General dependencies
RUN apt-get install -y emacs nano vim wget sudo pgloader

# Give postgres user sudo privileges
RUN usermod -a -G sudo postgres; \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER postgres

WORKDIR /var/lib/postgresql

VOLUME [ "/var/lib/postgresql" ]

# PostgreSQL's port
EXPOSE 5432
