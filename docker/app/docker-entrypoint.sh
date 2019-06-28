#!/bin/bash

if [[ $1 = "start" ]]; then
  mkdir -p /app/tmp/sockets /app/tmp/pids
  rm -f /app/tmp/sockets/* /app/tmp/pids/*

  bundle install --path vendor/bundle

  bundle exec rails webpacker:compile

  cp -rv /app/public/* /var/www/

  echo
  echo "start unicorn..."

  bundle exec unicorn --env production -c config/unicorn.rb
else
  exec "$@"
fi
