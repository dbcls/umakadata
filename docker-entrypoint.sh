#!/bin/bash

cd /myapp/web

source ~/.bashrc

mkdir -m 775 -p log tmp/pids

echo "installing dependencies..."
bundle install -j8 --path vendor/bundle

export SECRET_KEY_BASE=$(bundle exec rake secret)

echo "precompiling assets..."
bundle exec rake assets:precompile RAILS_ENV=${RAILS_ENV:-production}

echo "server will start soon..."
exec "$@"
