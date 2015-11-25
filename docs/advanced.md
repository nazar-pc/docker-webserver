# Advanced usage
Advanced usage includes ability to work with Docker 1.9+ Networking instead of links, ability to build cluster of multiple nodes that scale nicely and load balancing.

Good news: all your usual services like are already prepared for this. Just stop using links and switch to Docker Networking.

For instance, MariaDB instance is not a regular MariaDB server, but rather MariaDB Galera cluster with just one node, so you can scale it to multiple nodes at any time.

The same about PhpMyAdmin, Nginx, PHP-FPM and SSH images - they are all ready to work with Consul for DNS resolution, so you don't have to change your code at all, just modify declarative `docker-compose.yml` file.

Backup/restore images are still able to backup and restore your containers as it was before.

Upgrade/backup/restore procedures remain the same as when using links.

# Zero-configuration
All the features provided work with zero-configuration out of the box, all you need is declarative `docker-compose.yml` file.

IP addresses, configuration files and other stuff will be done for you completely automatically with reasonable defaults (which you can, of course, change at any time).

As you scale your services - new nodes will join existing cluster, removed nodes will leave cluster and failed instances will do their best to re-join existing cluster as soon as they start again.

Everything mentioned above makes building scalable infrastructure a breathe!

If you think some of the features are not configured as good as they can - feel free to open an issue or submit a pull request.

# Docker Networking
Docker 1.9 introduced new Networking feature that allows to create multiple networks and freely assign containers to them.

Since for our examples we'are using Docker Compose, you'll need version 1.5+ of it as well.

Before we start with full examples, some details of how it works.

When using links you can assign alias for come service when linking and thus you're able to use that name within other container:
```yml
data:
  image: nazarpc/webserver:data
  volumes_from:
    - example.com

mariadb:
  image: nazarpc/webserver:mariadb
  restart: always
  volumes_from:
    - data

phpmyadmin:
  image: nazarpc/phpmyadmin
  links:
    - mariadb:mysql
  restart: always
  ports:
    - 127.0.0.1:1234:80
```

Here service `mariadb` will be visible inside `phpmyadmin` container as `mysql`. This has 2 major weaknesses:
* it doesn't work with scaling
* with Docker Networking it doesn't work at all, Docker Compose will generate name like `project_mariadb_1` and you can't change it while preserving other features

**NOTE: In order to use Docker Networking with Docker Compose it is necessary to add `--x-networking` argument, so instead of `docker-compose up -d` we'll need `docker-compose --x-networking up -d`**

# Consul
Because of reasons above we need some DNS service to resolve names like `mysql` to service that we actually have, whatever name Docker Compose assigned to it.

For this purpose we'll use `nazarpc/webserver:consul` image. It will help us to create multiple services, assign aliases for each service and resolve services by their aliases through DNS:
```yml
...
consul:
  image: nazarpc/webserver:consul
  environment:
    CONSUL_SERVICE: consul
    SERVICES: nginx-haproxy:nginx, mariadb, mariadb:mysql
    MIN_SERVERS: 1
...
```
* `CONSUL_SERVICE` - OPTIONAL (defaults to `consul`), in this variable you should specify the same name as you name Consul service (you can in fact have multiple Consul services)
* `SERVICES` - REQUIRED, coma and/or space-separated list of services that Consul should provide through DNS with optional alias specified after colon
* `MIN_SERVERS` - OPTIONAL (defaults to `1`), Consul-specific feature (`-bootstrap-expect` CLI argument), if specified - Consul will wait until scaled to at least `MIN_SERVERS` before building cluster

In example above we have Consul node that will resolve all `nginx-haproxy` containers, no matter how may of them you have, by `nginx` host name, so you can call `ping nginx` in any other container and you'll get one of `nginx-haproxy` containers under the hood.
The same about `mariadb` containers - you can resolve them by either `mariadb` or `mysql` host names, since we've specified 2 aliases.

Consul instance is not a regular instance, it is cluster of 1 node, so you can scale cluster it to as many nodes as you need and they will all connect to each other and build single cluster.

By the way, `consul` will resolve to one of Consul instances through DNS automatically, you don't have to specify it manually.

# HAProxy
DNS resolution is great, but we also need to have high performance Load Balancing to scale our services flawlessly.

For this purpose we'll use `nazarpc/webserver:haproxy` image. It will help us to balance load to our services (TCP connections only) across multiple instances:
```yml
...
consul:
  image: nazarpc/webserver:consul
  environment:
    CONSUL_SERVICE: consul
    SERVICES: mariadb-haproxy:mysql

mariadb-haproxy:
  image: nazarpc/webserver:haproxy
  environment:
    SERVICE_NAME: mariadb
    SERVICE_PORTS: 3306
...
```
* `SERVICE_NAME` - REQUIRED, name of service for load balancing, for multiple services create multiple HAProxy services, they're lightweight, so you can create as many of them as needed
* `SERVICE_PORTS` - REQUIRED, coma and/or space-separated list of ports that HAProxy will listen, HAProxy works as transparent proxy, so input port is the same as output port

In example above whenever we refer to `mysql` host, it will be resolved to one of running `mariadb-haproxy` instances, and all requests to the port `3306` will be sent over to one of running `mariadb` instances.
If you scale `mariadb-haproxy` instance - Consul will start resolve ot one of them immediately.

# MariaDB
In order to scale MariaDB we'll need to build MariaDB Galera cluster.

`nazarpc/webserver:mariadb` image is in fact already a cluster with single node - so, it it ready to scale at any time with Master-Master replication mode.

NOTE: if you were using older versions of images when regular MariaDB instance was used - no worries, it will be automatically upgraded to MariaDB Galera cluster as soon as you upgrade.

Let's extend our previous example a bit:
```yml
data:
  image: nazarpc/webserver:data

consul:
  image: nazarpc/webserver:consul
  environment:
    CONSUL_SERVICE: consul
    SERVICES: mariadb-haproxy:mysql

mariadb-haproxy:
  image: nazarpc/webserver:haproxy
  environment:
    SERVICE_NAME: mariadb
    SERVICE_PORTS: 3306

mariadb:
  image: nazarpc/webserver:mariadb
  environment:
    SERVICE_NAME: mariadb
  volumes_from:
    - data
...
```
* `SERVICE_NAME` - OPTIONAL (defaults to `mariadb`), in this variable you should specify the same name as you name MariaDB service (you can in fact have multiple MariaDB services)

In example above whenever we refer to `mysql` host, it will be resolved to one of running `mariadb-haproxy` instances, and all requests to the port `3306` will be sent over to one of running `mariadb` instances.
If you scale `mariadb` instance - new nodes will join existing cluster, replicate, at the same time they'll be added to all HAProxy instances and as soon as ready will start serving users.

# PhpMyAdmin, Nginx, PHP-FPM and SSH
You don't need to do anything special to start using them, just add them to `docker-compose.yml` and they'l work:
```yml
phpmyadmin:
  image: nazarpc/webserver:phpmyadmin
  environment:
    CONSUL_SERVICE: consul
  ports:
    - 127.0.0.1:1234:80
```
* `CONSUL_SERVICE` - OPTIONAL (defaults to `consul`), in this variable you should specify the name of Consul service you want to use

# Combined example
```yml
# docker-compose.yml
data:
  image: nazarpc/webserver:data

consul:
  image: nazarpc/webserver:consul
  restart: always
  environment:
    SERVICES: mariadb-haproxy:mysql, nginx-haproxy:nginx, php-haproxy:php

mariadb-haproxy:
  image: nazarpc/webserver:haproxy
  restart: always
  environment:
    SERVICE_NAME: mariadb
    SERVICE_PORTS: 3306

mariadb:
  image: nazarpc/webserver:mariadb
  restart: always
  environment:
    SERVICE_NAME: mariadb
  volumes_from:
    - data

nginx-haproxy:
  image: nazarpc/webserver:haproxy
  restart: always
  environment:
    SERVICE_NAME: nginx
    SERVICE_PORTS: 80

nginx:
  image: nazarpc/webserver:nginx
  restart: always
  volumes_from:
    - data

php-haproxy:
  image: nazarpc/webserver:haproxy
  restart: always
  environment:
    SERVICE_NAME: php
    SERVICE_PORTS: 9000

php:
  image: nazarpc/webserver:php-fpm
  restart: always
  volumes_from:
    - data

public-nginx-haproxy:
  image: nazarpc/webserver:haproxy
  restart: always
  environment:
    SERVICE_NAME: nginx
    SERVICE_PORTS: 80
  ports:
    - 127.0.0.1:8080:80

public-nginx-haproxy-backup:
  image: nazarpc/webserver:haproxy
  restart: always
  environment:
    SERVICE_NAME: nginx
    SERVICE_PORTS: 80
  ports:
    - 127.0.0.1:8081:80

phpmyadmin:
  image: nazarpc/webserver:phpmyadmin
  restart: always
  ports:
    - 127.0.0.1:1234:80
```
```bash
docker-compose --x-networking up -d
docker-compose --x-networking scale consul=3 mariadb-haproxy=2 mariadb=3 nginx-haproxy=2 nginx=4 php-haproxy=2 php=4
```

After this we'll have:
* 3 Consul nodes in cluster
* 2 HAProxy instances for MariaDB load balancing
* 3 MariaDB Galera nodes in cluster with Master-Master replication mode
* 2 HAProxy instances for Nginx load balancing (internal use)
* 4 Nginx instances
* 2 HAProxy instances for PHP-FPM load balancing
* 4 PHP-FPM instances
* 2 HAProxy instances binded to `127.0.0.1` (on port `8080` as primary and port `8081` as backup in case when first fails) so we can access Nginx instances, also with load balancing
* 1 PhpMyAdmin instance to work with MariaDB Galera cluster in GUI mode

Of course, you can run it on top of Docker Swarm (but you'll need additional configuration to place nodes of the same service on different physical servers).

We'll not be able to scale `public-haproxy` and `phpmyadmin` services in this example since they have published ports, but this is what we expect in any case.

