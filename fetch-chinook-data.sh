#!/usr/bin/env bash
# Pull the Chinook music SQLite database and load it into PostgreSQL.
# From The Art of Postgres: Chapter 5, A Small Application

CHINOOK_POSTGRESQL_DB_NAME=chinook
CHINOOK_SQLITE_DATASOURCE=https://github.com/lerocha/chinook-database/raw/master/ChinookDatabase/DataSources/Chinook_Sqlite_AutoIncrementPKs.sqlite

until pg_isready 2>/dev/null; do
  echo "Waiting for postgres to start"
  sleep 1
done

if psql -lqt | cut -d \| -f 1 | grep -qw $CHINOOK_POSTGRESQL_DB_NAME; then
  if [[ $1 == "--recreate" ]]; then
    echo "--recreate flag was given, dropping database $CHINOOK_POSTGRESQL_DB_NAME"
    dropdb $CHINOOK_POSTGRESQL_DB_NAME
  else
    echo "Chinook PostgreSQL database already exists, skipping"
    echo "Include the --recreate flag if you want to drop and reseed the database"
    exit 1
  fi
fi

# echo "Creating PostgreSQL database"
createdb $CHINOOK_POSTGRESQL_DB_NAME

# echo "Fetching Chinook data and loading into local database"
pgloader $CHINOOK_SQLITE_DATASOURCE pgsql://postgres@127.0.0.1:5432/$CHINOOK_POSTGRESQL_DB_NAME
