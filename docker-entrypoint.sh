#!/bin/bash

cd /myapp/web
mkdir -p log tmp/pids

export SECRET_KEY_BASE=$(bundle exec rake secret)

if [ -e Gemfile ]; then
  echo "installing dependencies..."
  bundle install -j8

  echo "precompiling assets..."
  bundle exec rake assets:precompile RAILS_ENV=${RAILS_ENV:-production}
fi

exec "$@"
