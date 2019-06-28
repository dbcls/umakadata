FROM ruby:2.6.3

RUN curl -sL "https://deb.nodesource.com/setup_10.x" | bash - && \
    curl -sS "https://dl.yarnpkg.com/debian/pubkey.gpg" | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

RUN apt-get update && \
    apt-get install -y nodejs yarn && \
    rm -rf /var/lib/apt/lists/*

RUN echo -e "---\nBUNDLE_PATH: \"vendor/bundle\"" > /usr/local/bundle/config

ADD docker-entrypoint.sh /

WORKDIR app

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]
