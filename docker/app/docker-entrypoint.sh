#!/bin/bash

# nokogiri ships a precompiled aarch64-linux gem that is linked against glibc 2.29,
# but buster provides 2.28, so requiring it fails with a LoadError. The x86_64-linux
# gem only needs glibc 2.17 and is fine here, so restrict this to arm64 and leave
# amd64 builds on their (faster) precompiled gems.
#
# This has to be an environment variable rather than `bundle config`, because the
# compose files mount a volume over /usr/local/bundle, which would hide any config
# file baked into the image.
if [[ $(dpkg --print-architecture) = arm64 ]]; then
  export BUNDLE_FORCE_RUBY_PLATFORM=true
fi

if [[ $1 = start ]]; then
  mkdir -p /app/tmp/sockets /app/tmp/pids
  rm -f /app/tmp/sockets/* /app/tmp/pids/*

  bundle install
  yarn install

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
