# WebServer (MariaDB, PHP-FPM, Nginx) composed from several separate containers linked together
Currently WebServer consists of such containers:
* Data-only container (based on `busybox` image)
* MariaDB (based on official image)
* Nginx (based on official image)
* PHP-FPM (based on `nazarpc/php-fom` image, which is official image + bunch of frequently used PHP extensions)
* SSH (based on `phusion/baseimage` image, contains pre-installed `git`, `mc` and `wget` for your convenience)

# How to use
The most convenient way to use all this is [Docker Compose](https://docs.docker.com/compose/)

At first you'll need to create persistent data-only container that will store all files, databases, ssh keys and setting of all these things:
```
docker run --name example.com nazarpc/webserver:data
```

This container will start and stop immediately, that is OK.

After this create directory for your website, it will contain `docker-compose.yml` file and potentially more files you'll need:
```
mkdir example.com
```

Now create `docker-compose.yml` inside with following contents:

```
data:
  image: nazarpc/webserver:data
  volumes_from:
    - example.com

db:
  image: nazarpc/webserver:mariadb
  restart: always
  volumes_from:
    - data

nginx:
  image: nazarpc/webserver:nginx
  links:
    - php
#  ports:
#    - {ip where to bind}:{port on localhost where to bind}:80
  restart: always
  volumes_from:
    - data

php:
  image: nazarpc/webserver:php-fpm
  links:
    - db:mysql
  restart: always
  volumes_from:
    - data

#phpmyadmin:
#  image: nazarpc/phpmyadmin
#  links:
#    - db:mysql
#  restart: always
#  ports:
#    - {ip where to bind}:{port on localhost where to bind}:80

ssh:
  image: nazarpc/webserver:ssh
  restart: always
  volumes_from:
    - data
#  ports:
#    - {ip where to bind}:{port on localhost where to bind}:22
```

Now customize it as you like, feel free to comment-out or remove `db`, `php` or `ssh` container if you have just bunch of static files, also you can uncomment `phpmyadmin` container if needed.

When you're done with editing:
```
docker-compose up -d
```

That is it, you have whole WebServer up and running!

# Upgrade
You can easily upgrade your WebServer to new version of software.

At first, pull new images:
```
docker pull nazarpc/webserver:data
docker pull nazarpc/webserver:mariadb
docker pull nazarpc/webserver:nginx
docker pull nazarpc/webserver:php-fpm
docker pull nazarpc/webserver:ssh
```

Now just go into directory with `docker-compose.yml` and run already familiar command:
```
docker-compose up -d
```

All containers will be recreated from new images in few seconds.

# Backup
To make backup it is enough to backup `example.com` container you've created from the beginning:
```
docker export example.com > example.com.tar
```

All other containers are standard and doesn't contain anything important, that is why upgrade process is so simple.

# SSH
SSH might be needed to access files from outside, especially with git.

Before you enter ssh container via SSH for the first time, you need to create file `/data/.ssh/authorized_keys` and put your public key contents inside ([how to generate SSH keys](https://help.github.com/articles/generating-ssh-keys/#step-2-generate-a-new-ssh-key)).
For example, you can do that from Midnight Commander file manager
```
docker-compose run ssh mc
```

Now you should be able to access container as `git` user:
```
ssh git@example.com
```

Optionally you might want to do the same for root user, create `/root/.ssh/authorized_keys` file similarly

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
