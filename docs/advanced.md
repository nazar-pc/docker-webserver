# NOTE: Description below is highly experimental and might not work as expected or not work at all, DO NOT USE IN PRODUCTION!

# Advanced usage
Advanced usage includes ability to build cluster of multiple nodes that scale nicely and load balancing.

Good news: all your usual services like are already prepared for this, just need to be configured slightly differently.

For instance, MariaDB instance is not a regular MariaDB server, but rather MariaDB Galera cluster with just one node, so you can scale it to multiple nodes at any time.

The same about PhpMyAdmin, Nginx, PHP-FPM and SSH images - they are all ready to work in cluster, so you don't have to change your code at all, just modify declarative `docker-compose.yml` file.

# TODO: backup/restore/upgrade details needs to be updated here
Backup/restore images are still able to backup and restore your containers as it was before.

Upgrade/backup/restore procedures remain the same as before.

# Zero-configuration
All the features provided work with zero-configuration out of the box, all you need is declarative `docker-compose.yml` file.

IP addresses, configuration files and other stuff will be done for you completely automatically with reasonable defaults (which you can, of course, change at any time).

As you scale your services - new nodes will join existing cluster, removed nodes will leave cluster and failed instances will do their best to re-join existing cluster as soon as they start again.

Everything mentioned above makes building scalable infrastructure a breathe!

If you think some of the features are not configured as good as they can - feel free to open an issue or submit a pull request.

# Ceph
One of the first major issue that needs to be solved when creating cluster is storage. While Docker supports volumes and their drivers, they need a lot of manual work to configure them, would be much better to have something more portable.

We solve storage problem with Ceph, more precisely, with [Ceph FS](http://docs.ceph.com/docs/master/cephfs/).

In order for this to work, we create Ceph cluster and then mount necessary directories with [ceph-fuse](http://docs.ceph.com/docs/master/man/8/ceph-fuse/) so that multiple container on different nodes of the cluster will have access to the same files.

For this purpose we'll use `nazarpc/webserver:ceph` image. It can work in different modes, which is why we specify different commands:
```yml
# docker-compose.yml
version: '3.1'
services:
...
  ceph-mon:
    image: nazarpc/webserver:ceph
    command: mon
    restart: always

  ceph-osd:
    image: nazarpc/webserver:ceph
    command: osd
    restart: always

  ceph-mds:
    image: nazarpc/webserver:ceph
    command: mds
    restart: always
```
Currently it is not possible to specify scaling in YAML file, so we'll likely need to scale ceph nodes like following:
```bash
docker-compose scale ceph-mon=3 ceph-osd=3 ceph-mds=3
```
Main environment variables supported:
* `CONSUL_SERVICE` - OPTIONAL (defaults to `consul`), name of Consul service in `docker-compose.yml` declaration, needed for storing configuration
* `CEPH_MON_SERVICE` OPTIONAL (defaults to `ceph-mon`), name of Ceph monitor service in `docker-compose.yml` declaration, needed in order to find Ceph monitor nodes in cluster

NOTE: Any features supported by upstream [ceph/daemon](https://github.com/ceph/ceph-docker) image are inherently supported by this image.

# Consul
Consul is an integral piece of the cluster, since it is actually required for Ceph to store configuration

For this purpose we'll use `nazarpc/webserver:consul` image.
```yml
# docker-compose.yml
version: '3.1'
services:
...
  consul:
    image: nazarpc/webserver:consul
    restart: always
```
Currently it is not possible to specify scaling in YAML file (see [docker/compose#1661](https://github.com/docker/compose/issues/1661) and [docker/compose#2496](https://github.com/docker/compose/issues/2496)), so we'll likely need to scale Consul nodes (to at least `MIN_SERVERS`) like following:
```bash
docker-compose scale consul=3
```
Main environment variables supported:
* `CONSUL_SERVICE` - OPTIONAL (defaults to `consul`), name of Consul service in `docker-compose.yml` declaration (name of service itself actually), needed to find other Consul nodes in cluster
* `MIN_SERVERS` - OPTIONAL (defaults to `3`), Consul cluster will wait till `MIN_SERVERS` started before forming cluster and starting leader election

# HAProxy
Load Balancing is also an integral part of cluster robustness and performance. HAProxy might be used to hide behind multiple nodes under single entry point and distribute incoming requests across those nodes.
HAProxy is only useful for TCP connections.

For this purpose we'll use `nazarpc/webserver:haproxy` image, for instance:
```yml
# docker-compose.yml
version: '3.1'
services:
...
  mariadb-haproxy:
    image: nazarpc/webserver:haproxy
    restart: always
    environment:
      SERVICE_NAME: mariadb
      SERVICE_PORTS: 3306
```
Main environment variables supported:
* `SERVICE_NAME` - REQUIRED, name of service for load balancing, for multiple services create multiple HAProxy services, they're lightweight, so you can create as many of them as needed
* `SERVICE_PORTS` - REQUIRED, coma and/or space-separated list of ports that HAProxy will listen, HAProxy works as transparent proxy, so input port is the same as output port

In example above all requests to the host `mariadb-haproxy` and port `3306` will be sent over to one of running `mariadb` instances.
You can also scale `mariadb-haproxy` instance if needed.

# MariaDB
In order to scale MariaDB we'll need to build MariaDB Galera cluster.
`nazarpc/webserver:mariadb` image is in fact already a cluster with single node - so, it it ready to scale at any time with Master-Master replication mode.
# TODO: devices and cap_add are not working in Docker Swarm Mode
In order to actually scale MariaDB we just need to mount CephFS within container and everything else will happen automatically:
```yml
# docker-compose.yml
version: '3.1'
services:
...
  mariadb:
    image: nazarpc/webserver:mariadb
    restart: always
    environment:
      CEPHFS_MOUNT: 1
# In order to access FUSE
    devices:
      - /dev/fuse:/dev/fuse
# In order to mount CEPHFS
    cap_add:
      - SYS_ADMIN
```
Main environment variables supported:
* `SERVICE_NAME` - OPTIONAL (defaults to `mariadb`), name of MariaDB service in `docker-compose.yml` declaration, needed in order to find other MariaDB nodes in cluster
* `CEPH_MON_SERVICE` OPTIONAL (defaults to `ceph-mon`), name of Ceph monitor service in `docker-compose.yml` declaration, needed in order to find Ceph monitor nodes in cluster
* `CEPHFS_MOUNT` OPTIONAL (defaults to `0`), when set to `1`, container will try to mount CephFS on start

If you scale `mariadb` instance - new nodes will join existing cluster and start to replicate:
```bash
docker-compose scale mariadb=3
```

# Nginx, PHP-FPM and SSH
They are very similar to MariaDB in terms of configuration, but don't create clusters by themselves.
# TODO: devices and cap_add are not working in Docker Swarm Mode
All you need to specify is that CephFS should be mounted:
```yml
# docker-compose.yml
version: '3.1'
services:
...
  nginx:
    image: nazarpc/webserver:nginx
    restart: always
    environment:
      CEPHFS_MOUNT: 1
# In order to access FUSE
    devices:
      - /dev/fuse:/dev/fuse
# In order to mount CEPHFS
    cap_add:
      - SYS_ADMIN

  php:
    image: nazarpc/webserver:php-fpm
    restart: always
    environment:
      CEPHFS_MOUNT: 1
# In order to access FUSE
    devices:
      - /dev/fuse:/dev/fuse
# In order to mount CEPHFS
    cap_add:
      - SYS_ADMIN

  ssh:
    image: nazarpc/webserver:ssh
    restart: always
    environment:
      CEPHFS_MOUNT: 1
# In order to access FUSE
    devices:
      - /dev/fuse:/dev/fuse
# In order to mount CEPHFS
    cap_add:
      - SYS_ADMIN
```
Main environment variables supported (common to all 3 images):
* `CEPH_MON_SERVICE` OPTIONAL (defaults to `ceph-mon`), name of Ceph monitor service in `docker-compose.yml` declaration, needed in order to find Ceph monitor nodes in cluster
* `CEPHFS_MOUNT` OPTIONAL (defaults to `0`), when set to `1`, container will try to mount CephFS on start

# Combined example
# TODO: devices and cap_add are not working in Docker Swarm Mode
```yml
# docker-compose.yml
version: '3.1'
services:
  consul:
    image: nazarpc/webserver:consul
    restart: always

  ceph-mon:
    image: nazarpc/webserver:ceph
    command: mon
    restart: always

  ceph-osd:
    image: nazarpc/webserver:ceph
    command: osd
    restart: always

  ceph-mds:
    image: nazarpc/webserver:ceph
    command: mds
    restart: always

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
      CEPHFS_MOUNT: 1
# In order to access FUSE
    devices:
      - /dev/fuse:/dev/fuse
# In order to mount CEPHFS
    cap_add:
      - SYS_ADMIN

  nginx:
    image: nazarpc/webserver:nginx
    restart: always
    environment:
      CEPHFS_MOUNT: 1
# In order to access FUSE
    devices:
      - /dev/fuse:/dev/fuse
# In order to mount CEPHFS
    cap_add:
      - SYS_ADMIN

  php:
    image: nazarpc/webserver:php-fpm
    restart: always
    environment:
      CEPHFS_MOUNT: 1
# In order to access FUSE
    devices:
      - /dev/fuse:/dev/fuse
# In order to mount CEPHFS
    cap_add:
      - SYS_ADMIN

  phpmyadmin:
    image: nazarpc/webserver:phpmyadmin
    restart: always
    environment:
      MYSQL_HOST: mariadb
  
  ssh:
    image: nazarpc/webserver:ssh
    restart: always
    environment:
      CEPHFS_MOUNT: 1
# In order to access FUSE
    devices:
      - /dev/fuse:/dev/fuse
# In order to mount CEPHFS
    cap_add:
      - SYS_ADMIN
```
```bash
docker-compose up -d
docker-compose scale consul=3 ceph-mon=3 ceph-osd=3 ceph-mds=3 mariadb-haproxy=2 mariadb=3 nginx=2 php=3
```

After this we'll have:
* 3 Consul nodes in cluster
* Ceph cluster with 3 monitors, 3 OSDs and 3 metadata servers
* 2 HAProxy instances for MariaDB load balancing
* 3 MariaDB Galera nodes in cluster with Master-Master replication mode
* 2 Nginx instances
* 3 PHP-FPM instances
* 1 PhpMyAdmin instance to work with MariaDB Galera cluster in GUI mode
* 1 SSH server to access files and configs

# TODO: Extend example with Docker Swarm Mode
