FROM ruby:2.6.3-slim-buster

RUN mkdir -p /usr/share/man/man1 # workaround for installing openjdk-11-jre-headless

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      ca-certificates-java && \
    apt-get install -y --no-install-recommends \
      build-essential \
      curl \
      git \
      libpq-dev \
      libxml2-dev \
      libxslt-dev \
      nodejs \
      npm \
      shared-mime-info \
      openjdk-11-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN gem install bundler -v '< 2'

RUN curl -sL https://nodejs.org/download/release/v14.21.3/node-v14.21.3-linux-x64.tar.gz | tar xz -C /usr/local --strip-components=1

RUN npm install -g yarn

# Avoid key length error on client side
RUN sed -i -e 's/CipherString = DEFAULT@SECLEVEL=2/# CipherString = DEFAULT@SECLEVEL=2/g' /etc/ssl/openssl.cnf

ADD docker-entrypoint.sh /

WORKDIR app

EXPOSE 3000 3035 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]
