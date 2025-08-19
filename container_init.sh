#!/bin/sh

set -e

exec ./docker/entrypoints/rails.sh bundle exec rails s -p 3000 -b 0.0.0.0