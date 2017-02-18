# WebServer (MariaDB, PHP-FPM, Nginx) composed from several separate containers linked together
Currently WebServer consists of such images:
* Data-only container (based on official `debian:jessie` image)
* logrotate container (based on official `debian:jessie` image)
* MariaDB (based on official `MariaDB` image)
* Nginx (based on official `Nginx` image)
* PHP-FPM (based on `nazarpc/php:fpm` image, which is official image + bunch of frequently used PHP extensions)
* SSH (based on `phusion/baseimage` image, contains pre-installed `curl`, `git`, `mc`, `wget`, `php-cli` and `composer` for your convenience)
* PhpMyAdmin (based on `nazarpc/phpmyadmin` image, which is official php image with Apache2, where PhpMyAdmin was installed)
* Consul (based on official `debian:jessie` image)
* HAProxy (based on official `haproxy` image)
* backup container (based on official `debian:jessie` image)
* restore container (based on official `debian:jessie` image)
* [nazarpc/webserver-apps](https://github.com/nazar-pc/docker-webserver-apps) for ready to use applications that plays nicely with images mentioned above

# How to use
The most convenient way to use all this is [Docker Compose](https://docs.docker.com/compose/)

At first you'll need to create persistent data-only container that will store all files, databases, ssh keys and settings of all these things:
```
docker run --name example.com nazarpc/webserver:data
```

This container will start and stop immediately, that is OK.

After this create directory for your website, it will contain `docker-compose.yml` file and potentially more files you'll need:
```
mkdir example.com
cd example.com
```

Now create `docker-compose.yml` inside with following contents:

```yml
version: '2'
services:
  data:
    image: nazarpc/webserver:data
    volumes_from:
      - container:example.com
  
  logrotate:
    image: nazarpc/webserver:logrotate
    restart: always
    volumes_from:
      - data
  
  mariadb:
    image: nazarpc/webserver:mariadb
    restart: always
    volumes_from:
      - data
  
  nginx:
    image: nazarpc/webserver:nginx
    links:
      - php
#    ports:
#      - {ip where to bind}:{port on localhost where to bind}:80
    restart: always
    volumes_from:
      - data
  
  php:
    image: nazarpc/webserver:php-fpm
    links:
      - mariadb:mysql
    restart: always
    volumes_from:
      - data
  
#  phpmyadmin:
#    image: nazarpc/webserver:phpmyadmin
#    links:
#      - mariadb:mysql
#    restart: always
#    ports:
#      - {ip where to bind}:{port on localhost where to bind}:80
  
  ssh:
    image: nazarpc/webserver:ssh
    restart: always
    volumes_from:
      - data
#    ports:
#      - {ip where to bind}:{port on localhost where to bind}:22
#    environment:
#      - PUBLIC_KEY={your public SSH key}
```

Now customize it as you like, feel free to comment-out or remove `mariadb`, `php` or `ssh` container if you have just bunch of static files, also you can uncomment `phpmyadmin` container if needed.

When you're done with editing:
```
docker-compose up -d
```

That is it, you have whole WebServer up and running!

**Also you might be interested in [advanced examples](docs/advanced.md) with load balancing and scaling across cluster.**

# Upgrade
You can easily upgrade your WebServer to new version of software.

Using Docker Compose upgrade is very simple:
```
docker-compose pull
docker-compose up -d
```
All containers will be recreated from new images in few seconds.

Backup/restore images are not present in `docker-compose.yml`, so if you're using them - pull them manually.

Alternatively you can pull all images manually:
```
docker pull nazarpc/webserver:data
docker pull nazarpc/webserver:logrotate
docker pull nazarpc/webserver:mariadb
docker pull nazarpc/webserver:nginx
docker pull nazarpc/webserver:php-fpm
docker pull nazarpc/webserver:ssh
docker pull nazarpc/webserver:backup
docker pull nazarpc/webserver:restore
```

And again in directory with `docker-compose.yml`:
```
docker-compose up -d
```

# Backup
To make backup you need to only backup volumes of data-only container. The easiest way to do that is using `nazarpc/webserver:backup` image:
```
docker run --rm --volumes-from=example.com -v /backup-on-host:/backup --env BACKUP_FILENAME=new-backup nazarpc/webserver:backup
```

This will result in `/backup-on-host/new-backup.tar` file being created - feel free to specify other directory and other name for backup file.

All other containers are standard and doesn't contain anything important, that is why upgrade process is so simple.

**NOTE: You'll likely want to stop MariaDB instance before backup (it is enough to stop master node in case of MariaDB cluster with 2+ nodes)**

# Restore
Restoration from backup is not more difficult that making backup, there is `nazarpc/webserver:restore` image for that:
```
docker run --rm --volumes-fromexample.com -v /backup-on-host/new-backup.tar:/backup.tar nazarpc/webserver:restore
```

That is it, empty just created `example.com` container will be filled with data from backup and ready to use.

# SSH
SSH might be needed to access files from outside, especially with git.

Before you enter ssh container via SSH for the first time, you need to specify public SSH key ([how to generate SSH keys](https://help.github.com/articles/generating-ssh-keys/#step-2-generate-a-new-ssh-key)).
The easiest way to do this is to define `PUBLIC_KEY` environment variable in `docker-compose.yml`.
Alternatively you can create file `/data/.ssh/authorized_keys` and put your public key contents inside.
For example, you can do that from Midnight Commander file manager:
```
docker-compose run ssh mc
```

When public SSH key is added you should be able to access container as `git` user:
```
ssh git@example.com
```

# Internal structure
Internally all that matters is `/data` directory - it contains all necessary symlinks for your convenience - here you can see files for Nginx and MariaDB, their logs and configs, PHP-FPM's config, SSH config and SSH keys directory.
That is all what will be persistent, everything else outside `/data` will be lost during upgrade.

# Update configuration
If you update some configuration - you don't need to restart everything, restart only things you need, for instance:
```
docker-compose restart nginx
```

# License
MIT license, see license.txt
