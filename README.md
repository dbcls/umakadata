# Umakadata

## Prerequisites

* Docker
* Docker Compose

## Architecture

* Ruby
  - 2.6.3

* Ruby on Rails 
  - 5.2

* Node.js
  - 12.x (LTS)

* Middlewares
  - nginx 1.17
  - PostgreSQL 11.4
  - redis 5.0

## Setting up

1. Copy compose file

    ```
    $ cp docker-compose.prod.yml docker-compose.yml
    ```

1. Build images

    ```
    $ docker-compose build
    ```

1. Create environment file as follows

    ```
    $ cat .env
    UMAKADATA_DATABASE_USERNAME=umakadata
    UMAKADATA_DATABASE_PASSWORD=(CHANGEME)

    UMAKADATA_REDIS_HOST=redis

    SIDEKIQ_USER=admin
    SIDEKIQ_PASSWORD=(CHANGEME)

    UMAKADATA_MAILER_DEFAULT_URL_HOST=(YOUR_URL_HOST)

    # Recipient of inquary mail
    UMAKADATA_MAILER_DEFAULT_TO=to@example.com

    # Sender of crawler notification
    UMAKADATA_MAILER_CRAWL_MAILER_FROM=from@example.com

    # Recipient of crawler notification
    UMAKADATA_MAILER_CRAWL_MAILER_TO=to@example.com

    # umakadata uses SendGrid as MTA (Get API key on https://sendgrid.com)
    UMAKADATA_SENDGRID_API_KEY=

    # (optional) set if you would like to use reCAPTCHA (Get API keys on https://www.google.com/recaptcha/about/)
    UMAKADATA_RECAPTCHA_SITE_KEY=
    UMAKADATA_RECAPTCHA_SECRET_KEY=
    ```

1. Install dependencies

    ```
    $ docker-compose run --rm app bundle install
    $ docker-compose run --rm app yarn install
    ```

1. Database initialization

    ```
    $ docker-compose run --rm app rails db:create
    $ docker-compose run --rm app rails db:migrate
    ```

1. Start application

    ```
    $ docker-compose up -d
    ```
