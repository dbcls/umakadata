FROM ruby:2.6.3-slim-buster

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl && \
    rm -rf /var/lib/apt/lists/* && \
    curl -sL "https://deb.nodesource.com/setup_12.x" | bash - && \
    curl -sS "https://dl.yarnpkg.com/debian/pubkey.gpg" | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      git \
      libpq-dev \
      libxml2-dev \
      libxslt-dev \
      nodejs \
      yarn && \
    rm -rf /var/lib/apt/lists/*

RUN gem install bundler -v '< 2'

# Avoid key length error on client side
RUN sed -i -e 's/CipherString = DEFAULT@SECLEVEL=2/# CipherString = DEFAULT@SECLEVEL=2/g' /etc/ssl/openssl.cnf

ADD docker-entrypoint.sh /

WORKDIR app

EXPOSE 3000 3035 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]
