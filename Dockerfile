FROM ruby:2.2.0

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

# Re-install bundler (Installation for bundler 1.11.2 is performed in the base image, but it is no effect.)
ENV BUNDLER_VERSION 1.11.2
RUN gem install bundler --version "$BUNDLER_VERSION"

RUN mkdir /myapp
ADD . /myapp
WORKDIR /myapp/web

RUN bundle install
