#!/bin/bash

if [[ $1 = start ]]; then
  mkdir -p /app/tmp/sockets /app/tmp/pids
  rm -f /app/tmp/sockets/* /app/tmp/pids/*

  if [[ $RAILS_ENV = production ]]; then
    PROCFILE=${PROCFILE:-Procfile}
    rails assets:precompile
    mkdir -p /var/www
    cp -rv /app/public/* /var/www/
  else
    PROCFILE=${PROCFILE:-Procfile.dev}
  fi

  echo
  echo "start foreman..."

  foreman start -f "$PROCFILE"
else
  exec "$@"
fi
