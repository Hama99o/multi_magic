#!/bin/sh
set -o errexit

echo "[render-start] Running migrations"
bundle exec rails db:migrate

echo "[render-start] Starting Rails server"
bundle exec rails server -b 0.0.0.0
