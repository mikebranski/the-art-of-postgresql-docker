#!/usr/bin/env bash

# Pull the f1db racing database and load it into PostgreSQL.
# From The Art of Postgres: Chapter X, YYYYYYYYYY

set -e

NC='\033[0m' # No color (reset)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

F1DB_DB_NAME=f1db
F1DB_SQLITE_DATASOURCE=http://ergast.com/downloads/f1db.sql.gz

echo -e "${GREEN}Fetching latest version of f1db...${NC}"
wget $F1DB_SQLITE_DATASOURCE -Nq
gunzip -kf f1db.sql.gz

echo -e "${GREEN}Installing and starting MariaDB...${NC}"
sudo apt-get update > /dev/null
sudo apt-get install -y mariadb-server mariadb-client > /dev/null
sudo /etc/init.d/mysql start > /dev/null

until pg_isready > /dev/null && pgrep mysql | wc -l > /dev/null; do
  echo -e "${YELLOW}Waiting for PostgreSQL and MySQL to start${NC}"
  sleep 1
done

echo -e "${GREEN}Creating intermediary MariaDB database and importing f1db data...${NC}"
sudo mysql -u root -e "DROP DATABASE IF EXISTS $F1DB_DB_NAME;"
sudo mysql -u root -e "CREATE DATABASE $F1DB_DB_NAME;"
sudo mysql -u root -e "USE $F1DB_DB_NAME; SOURCE f1db.sql;"

sudo mysql -e "CREATE USER IF NOT EXISTS 'postgres'@'localhost';"
sudo mysql -e "CREATE USER IF NOT EXISTS 'postgres'@'$HOST_IP';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'postgres'@'localhost';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'postgres'@'$HOST_IP';"

if psql -lqt | cut -d \| -f 1 | grep -qw $F1DB_DB_NAME; then
  if [[ $1 == "--recreate" ]]; then
    echo -e "${YELLOW}--recreate flag was given, dropping database $F1DB_DB_NAME${NC}"
    dropdb $F1DB_DB_NAME
  else
    echo -e "${RED}$F1DB_DB_NAME PostgreSQL database already exists, skipping${NC}"
    echo -e "${RED}Include the --recreate flag if you want to drop and reseed the database${NC}"
    exit 1
  fi
fi

echo -e "${GREEN}Creating PostgreSQL database...${NC}"
createdb $F1DB_DB_NAME

echo -e "${GREEN}Migrating f1db data from MySQL to PostgreSQL${NC}"
pgloader \
  mysql://postgres@localhost/$F1DB_DB_NAME \
  pgsql://postgres@localhost/$F1DB_DB_NAME \
  > /dev/null

echo -e "${GREEN}Cleaning up...${NC}"
sudo mysql -u root -e "DROP DATABASE IF EXISTS $F1DB_DB_NAME;"
sudo /etc/init.d/mysql stop > /dev/null
yes | sudo apt-get autoremove --purge mariadb-server mariadb-client > /dev/null
rm f1db.sql

echo -e "${GREEN}Done! 🎉${NC}"
