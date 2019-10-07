# Umakadata

* Ruby version

2.6.0+

* Setting up

```
docker-compose run app bundle install --path vendor/bundle
docker-compose run app yarn install
```

* Database creation

```
docker-compose run app bundle exec rails db:create
```

* Database initialization

```
docker-compose run app bundle exec rails db:migrate
```

* Deployment instructions

```
docker run -p 5432:5432 -e POSTGRES_USER=umakadata -e POSTGRES_PASSWORD=umakadata --name umakadata_postgres -d --rm postgres:11
docker run -p 6379:6379 --name umakadata_redis -d --rm redis:5.0 redis-server --appendonly yes
```
