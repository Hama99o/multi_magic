#!/usr/bin/env bash

# Exit on error
set -o errexit

echo "[render-build] Installing gems"
bundle install

echo "[render-build] Precompiling assets"
bin/rails assets:precompile
bin/rails assets:clean

# If you have a paid instance type, we recommend moving
# database migrations like this one from the build command
# to the pre-deploy command.
echo "[render-build] Running migrations"
bin/rails db:migrate

echo "[render-build] Done"
