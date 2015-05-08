# Nominatim Docker

Run [http://wiki.openstreetmap.org/wiki/Nominatim](http://wiki.openstreetmap.org/wiki/Nominatim) in a docker container.

This version uses Nominatim the Nominatim 2.4 Release.

Uses Ubuntu 14.04 and PostgreSQL 9.3

# Country
It downloads Europe/Monacco (latest) from geofabrik.de.

If a different country should be used, change the wget line in the Dockerfile to pull a different country file.
# Building

To rebuild the image locally execute

```
docker build -t nominatim .
```

# Running

By default the container exposes port `8080` To run the container execute

```
# remove any existing containers
docker rm -f nominatim_container || echo "nominatim_container not found, skipping removal"
docker run -p 8080:8080 --name nominatim_container --detach nominatim
```

Check the logs of the running container

```
docker logs nominatim_container
```

Stop the container
```
docker stop nominatim_container
```

Connect to the nominatim webserver with curl. If this succeeds, open [http://localhost:8080/](http:/localhost:8080) in a web browser

```
curl "http://localhost:8080"
```
