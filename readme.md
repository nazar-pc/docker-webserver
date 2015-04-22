# WebServer (MariaDB, PHP-FPM, Nginx) composed from several separate containers linked together
Currently WebServer consists of such containers:
* Data-only container (based on `busybox` image)
* MariaDB (based on official image)
* Nginx (based on official image)
* PHP-FPM (based on `nazarpc/php-fom` image, which is official image + bunch of frequently used PHP extensions)
* SSH (based on `phusion/baseimage` image, contains pre-installed `git`, `mc` and `wget` for your convenience)

Also there is sample `docker-compose.yml` which can be used to start all these services linked together using `Compose`.

Still in experimental stage, need to figure out how to run it even more conveniently (including Nginx config, creating DB and import SQL dump on first start, etc.).

# License
MIT license, see license.txt
