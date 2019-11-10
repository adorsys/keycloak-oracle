# Install keycloak and oracle database

## Clone this project

We assume DEV> is your development directory. We will alway use "cd $DEV" to indicate a change back to your $DEV directory.

```
DEV> git clone https://github.com/adorsys/keycloak-oracle.git

```
## Install oracle-xe in a docker container

```
DEV> git clone https://github.com/oracle/docker-images.git oracle-docker-images

```
see: https://github.com/oracle/docker-images/tree/master/OracleDatabase
Register and Download oracle-database-xe-18c-1.0-1.x86_64.rpm from the oracle website at https://www.oracle.com/database/technologies/xe-downloads.html or directly navigate to https://download.oracle.com/otn/linux/oracle18c/xe/oracle-database-xe-18c-1.0-1.x86_64.rpm

copy the downloaded file. On the mac you will have the following command. 

```
DEV> cp ~/Downloads/oracle-database-xe-18c-1.0-1.x86_64.rpm oracle-docker-images/OracleDatabase/SingleInstance/dockerfiles/18.4.0/
```

Start virtualbox and increase the RAM of you docker host for base memory of at least 6144 MB

```
# The install oracle

DEV> cd oracle-docker-images/OracleDatabase/SingleInstance/dockerfiles/

DEV/oracle-docker-images/OracleDatabase/dockerfiles> ./buildDockerImage.sh -v 18.4.0 -x
...
...
# This will take some time to install oracle xe
...

# If you encounter an error looking like:
This system does not meet the minimum requirements for swap space.  Based on
the amount of physical memory available.....
# then just stop and start the container and try aggain
...

# After a successfull installation, you have the following message
  Oracle Database Docker Image for 'xe' version 18.4.0 is ready to be extended: 
    
    --> oracle/database:18.4.0-xe

  Build completed in 386 seconds.
  
```

# Run oracle xe
Beware that we use "adorsys" as system password. This shall not be done on a productive server. 
```

DEV> cd keycloak-oracle

DEV> docker network create keycloak-network

DEV/keycloak-oracle> docker run --rm --name oracle --net keycloak-network --shm-size=1g -p 1521:1521 -p 8081:8080 -e ORACLE_PWD=adorsys -v /u01/app/oracle/oradata -v $PWD/setup:/u01/app/oracle/scripts/setup oracle/database:18.4.0-xe

# Beware our scrpit $DEV/keycloak-oracle/setup/init-oracle-xe.sql creates the user keyclaok with a password.

```

# Make oracle available under the domain name "oracle"

before you install keycloak, make sure you can reach the oracle docker under the dns oracle.

# Install Keycloak
DEV/keycloak-oracle> docker run --rm --name keycloak --net keycloak-network -e DB_VENDOR=oracle -p 8080:8080 -v $PWD/ojdbc8-full:/opt/jboss/keycloak/modules/system/layers/base/com/oracle/jdbc/main/driver jboss/keycloak:7.0.1



