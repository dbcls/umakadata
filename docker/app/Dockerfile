FROM ruby:2.6.3-slim-buster

RUN mkdir -p /usr/share/man/man1 # workaround for installing openjdk-11-jre-headless

# Debian buster is EOL: deb.debian.org no longer serves it and returns 404 on the
# Release file. The packages live on archive.debian.org, whose Release files are
# long past their Valid-Until date, so that check has to be relaxed as well.
RUN echo 'deb http://archive.debian.org/debian buster main' \
      > /etc/apt/sources.list && \
    echo 'deb http://archive.debian.org/debian-security buster/updates main' \
      >> /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' \
      > /etc/apt/apt.conf.d/99no-check-valid-until

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

# Derive the architecture rather than hardcoding x64, so the image also builds on
# arm64 hosts (Apple Silicon).
RUN case "$(dpkg --print-architecture)" in \
      amd64) NODE_ARCH=x64 ;; \
      arm64) NODE_ARCH=arm64 ;; \
      *) echo "unsupported architecture: $(dpkg --print-architecture)" >&2; exit 1 ;; \
    esac && \
    curl -sL "https://nodejs.org/download/release/v14.21.3/node-v14.21.3-linux-${NODE_ARCH}.tar.gz" \
      | tar xz -C /usr/local --strip-components=1

RUN npm install -g yarn

# Avoid key length error on client side
RUN sed -i -e 's/CipherString = DEFAULT@SECLEVEL=2/# CipherString = DEFAULT@SECLEVEL=2/g' /etc/ssl/openssl.cnf

ADD docker-entrypoint.sh /

WORKDIR app

EXPOSE 3000 3035 8080

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]
