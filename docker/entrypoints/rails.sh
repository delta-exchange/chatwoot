#!/bin/sh

set -ex

# Remove a potentially pre-existing server.pid for Rails.
rm -rf /app/tmp/pids/server.pid
rm -rf /app/tmp/cache/*

#[ Ensure a consistent bundle path if not provided ]
[ -z "$BUNDLE_PATH" ] && export BUNDLE_PATH=/gems

echo "Waiting for postgres to become ready...."

# Let DATABASE_URL env take presedence over individual connection params.
# This is done to avoid printing the DATABASE_URL in the logs
$(docker/entrypoints/helpers/pg_database_url.rb)
PG_READY="pg_isready -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USERNAME"

until $PG_READY
do
  sleep 2;
done

echo "Database ready to accept connections."

#install missing gems for local dev as we are using base image compiled for production
bundle install || { echo "bundle install failed, see logs above" >&2; exit 1; }

ATTEMPTS=5
i=1
while ! bundle check; do
  echo "bundle check failed, attempt $i/$ATTEMPTS. Running bundle install..."
  bundle install --jobs=4 --retry=3 || true
  if [ $i -ge $ATTEMPTS ]; then
    echo "Bundler dependencies are not satisfied after $ATTEMPTS attempts. Exiting." >&2
    bundle check || true
    exit 1
  fi
  i=$((i+1))
  sleep 2
done

# Execute the main process of the container
exec "$@"
