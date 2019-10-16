#!/usr/bin/env bash

# Pull the f1db racing database and load it into PostgreSQL.
# From The Art of Postgres: Chapter X, YYYYYYYYYY

set -e

F1DB_DB_NAME=f1db
F1DB_SQLITE_DATASOURCE=http://ergast.com/downloads/f1db.sql.gz

echo "Fetching latest version of f1db..."

wget $F1DB_SQLITE_DATASOURCE -Nq
gunzip -kf f1db.sql.gz

echo "Starting MySQL..."

sudo /etc/init.d/mysql start > /dev/null

until pg_isready > /dev/null && pgrep mysql | wc -l > /dev/null; do
  echo "Waiting for PostgreSQL and MySQL to start"
  sleep 1
done

echo "Creating intermediary MySQL database and importing f1db data..."

# Create MySQL user
sudo mysql -e "CREATE USER IF NOT EXISTS 'mysql'@'%';"
sudo mysql -e "SET PASSWORD FOR 'mysql'@'%' = PASSWORD('artofpostgres');"
# sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'mysql'@'%';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'mysql'@'%' IDENTIFIED BY 'artofpostgres' WITH GRANT OPTION;"
sudo mysql -e "FLUSH PRIVILEGES;"

# Create MySQL database and import F1DB data
sudo mysql -e "DROP DATABASE IF EXISTS f1db; CREATE DATABASE f1db;"
sudo mysql f1db < f1db.sql

if psql -lqt | cut -d \| -f 1 | grep -qw $F1DB_DB_NAME; then
  if [[ $1 == "--recreate" ]]; then
    echo "--recreate flag was given, dropping database $F1DB_DB_NAME"
    dropdb $F1DB_DB_NAME
  else
    echo "$F1DB_DB_NAME PostgreSQL database already exists, skipping"
    echo "Include the --recreate flag if you want to drop and reseed the database"
    exit 1
  fi
fi

echo "Creating PostgreSQL database..."
createdb $F1DB_DB_NAME

echo "Migrating f1db data from MySQL to PostgreSQL"

pgloader \
  mysql://mysql:artofpostgres@0.0.0.0:3306/$F1DB_DB_NAME \
  pgsql://postgres@0.0.0.0:5432/$F1DB_DB_NAME

echo "Done!"
