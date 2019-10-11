# Docker for TAOP
A basic postgres Docker setup for going through [The Art of PostgreSQL](https://tapoueh.org/)
by Dimitri Fontaine. It uses the official PostgreSQL 9 (what the book uses)
Docker image and comes with `pgloader`. Data is stored in `pgdata` as a mounted
volume mapped to `/var/lib/postgresql/data` in the container for persistence.

A `.psqlrc` file is included, along with three text editors: emacs, nano and
vim. You can choose your favorite and set it in the `.psqlrc` file (the default
is `nano` for the broadest accessibility).

# Using
First, build the image and bring the container up.

```shell
docker-compose up --build
```

Next, connect using your postgresql client of choice.

## `psql`
```shell
$ docker exec -it artofpostgres bash
> psql
```

## GUI
Point your graphical client to `postgresql://postgres@127.0.0.1:5440`.

# Chinook data
You can seed the Chinook database used in TAOP using the provided
`fetch-chinook-data.sh` script.

```shell
$ docker exec -it artofpostgres fetch-chinook-data.sh
```
