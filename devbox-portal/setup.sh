#!/bin/bash

# Start Postgres
if command -v docker-compose &> /dev/null; then
  docker-compose up -d
else
  echo "docker-compose not installed"
fi

# Set env vars
export DATABASE_URL=postgresql://backstage:backstage@localhost:5432/backstage
