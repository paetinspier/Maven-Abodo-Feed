#!/bin/bash
set -e

# Wait until PostgreSQL is ready
until pg_isready -h $DATABASE_HOST -U $DATABASE_USERNAME > /dev/null 2>&1; do
  echo "Waiting for database..."
  sleep 1
done

# Run setup tasks
bundle exec rake db:create db:migrate

# Your custom rake task
bundle exec rake property:import

# Start the Rails server
exec "$@"

