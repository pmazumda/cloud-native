#!/bin/bash
psql -U backstage -d backstage -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";'