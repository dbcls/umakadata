# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

```
docker-compose run app bundle exec rails db:create
```

* Database initialization

```
docker-compose run app bundle exec rails db:migrate
```

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

```
docker run -p 5432:5432 -e POSTGRES_USER=umakadata -e POSTGRES_PASSWORD=umakadata --name umakadata_postgres -d --rm postgres:11
docker run -p 6379:6379 --name umakadata_redis -d --rm redis:5.0 redis-server --appendonly yes
```

* ...
