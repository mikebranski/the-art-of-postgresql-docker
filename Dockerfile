FROM postgres:9

RUN apt-get update
# These are broken up so unchanged layers can remain cached while new
# dependencies are added
# General dependencies
RUN apt-get install -y emacs nano vim wget sudo
RUN apt-get install -y pgloader
RUN apt-get install -y mysql-server

# Give postgres user sudo privileges
RUN usermod -a -G sudo postgres; \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER postgres

WORKDIR /var/lib/postgresql

VOLUME [ "/var/lib/postgresql" ]

# PostgreSQL's port
EXPOSE 5432
