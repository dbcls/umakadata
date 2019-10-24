#!/bin/bash

if [[ $1 = "start" ]]; then
  mkdir -p /app/tmp/sockets /app/tmp/pids
  rm -f /app/tmp/sockets/* /app/tmp/pids/*

  bundle install --path vendor/bundle

  bundle exec rails assets:precompile

  cp -rv /app/public/* /var/www/

  echo
  echo "start foreman..."

  bundle exec foreman start
else
  exec "$@"
fi
