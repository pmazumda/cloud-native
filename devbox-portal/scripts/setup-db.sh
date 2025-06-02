#!/usr/bin/env bash

set -e

echo "Creating local PostgreSQL database (if not exists)..."

# Default creds (insecure, for local DevBox demo only)
PGUSER=postgres
PGDB=backstage

# Try creating DB
psql -U $PGUSER -tc "SELECT 1 FROM pg_database WHERE datname = '$PGDB'" | grep -q 1 || \
  psql -U $PGUSER -c "CREATE DATABASE $PGDB"

echo "Database '$PGDB' ready."
