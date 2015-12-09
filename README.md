# NYLAS Sync Engine
This docker images runs the nylas sync-engine in a a dedicated container.
The sync engine provides a RESTful API to the nylas N1 mail client. More information about this products can be found on https://www.nylas.com and on their github repositories https://github.com/nylas/sync-engine and https://github.com/nylas/N1

It is designed to work with :
* a mysql container linked with name `mysql`
* a redis container linked with name `redis`

# Running the container
To help running the sync engine, you can have a look to the sample `docker-compose.yml` provided in this project.
```yaml
#docker-compose.yml
sync-engine:
  image: nhurel/nylas-sync-engine
  ports:
    - 5555:5555
  links:
    - mysql:mysql
    - redis:redis
  hostname: sync-engine
  log_opt:
    max-size: "10m"
    max-file: "10"

mysql:
  image: mysql
  environment:
    - MYSQL_ROOT_PASSWORD=root
  volumes:
    - nylas_mysql:/var/lib/mysql
  log_opt:
    max-size: "10m"
    max-file: "10"

redis:
  image: redis
  volumes:
    - nylas_redis:/data
  log_opt:
    max-size: "10m"
    max-file: "10"

```

## Important
The sync engine uses its own hostname when saving data in the database and queries only datas matching its hostname. So, in order to be able to remove and recreate your container you **must** specify the hostname to the container. This is done by the docker-compose.yml file given or by using the `--hostname` parameter from the command line

# Database initialisation
At startup, the container should initialise nylas database. If it fails, you can log in the container and run the database initialisation script. Assuming your container's name is `nylas-sync-engine`, simply run :
```bash
docker exec -it nylas-sync-engine bash
bin/create-db
exit
```

# Account creation
Once your sync-engine container is up and running, you can add your first email account by logging in the container and running the account creation script. Assuming your container's name is still `nylas-sync-engine`, simply run :
```bash
docker exec -it nylas-sync-engine bash
bin/inbox-auth your.address@gmail.com
```
Follow the instruction and exit the container when done. You can curl the `/accounts` URL to check your account appears.

# Getting your mail
Unless you're running this sync engine on your personal computer, you'll have to rebuild the N1 package before installing it, to be able to configure your sync engine address. Guess what ? There's a docker image for that too !
