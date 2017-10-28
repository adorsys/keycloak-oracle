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
Register and Download oracle-xe-11.2.0-1.0.x86_64.rpm.zip from the oracle website.

copy the downloaded file. On the mac you will have the following command. 

```
DEV> cp ~/Downloads/oracle-xe-11.2.0-1.0.x86_64.rpm.zip oracle-docker-images/OracleDatabase/dockerfiles/11.2.0.2/

```
install docker-machine if not yet done

create a docker host with the name "oracle". Whereby oracle will be the name of the oracle docker container on you machine.

```
DEV> docker-machine create -d virtualbox oracle
...
...

# Use "docker-machine ls" to see the new container
DEV> docker-machine ls
NAME      ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER        ERRORS
oracle    -        virtualbox   Running   tcp://192.168.99.100:2376           v17.10.0-ce

# stop the host 
DEV> docker-machine stop oracle

```
Start virtualbox and increase the RAM of you docker host.
- On virtulbox, select the vm name oracle
- click on settings
- click on System
- Assign a base memory of 6144 MB
- click on ok
Go back to the terminal

```
# start the docker host oracle
DEV> docker-machine start oracle
# Connect your terminal to oracle
DEV> eval $(docker-machine env oracle)
DEV> docker-machine ls
NAME      ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER        ERRORS
oracle    *        virtualbox   Running   tcp://192.168.99.100:2376           v17.10.0-ce

# The star shows that you are connected to the docker host.

# The install oracle

DEV> cd oracle-docker-images/OracleDatabase/dockerfiles

DEV/oracle-docker-images/OracleDatabase/dockerfiles> ./buildDockerImage.sh -v 11.2.0.2 -x
...
...
# This will take some time to install oracle xe
...

# If you encounter an error looking like:
This system does not meet the minimum requirements for swap space.  Based on
the amount of physical memory available.....
# then just stop and start the container and try aggain
DEV/oracle-docker-images/OracleDatabase/dockerfiles> docker-machine stop oracle
DEV/oracle-docker-images/OracleDatabase/dockerfiles> docker-machine start oracle
DEV/oracle-docker-images/OracleDatabase/dockerfiles> eval $(docker-machine env oracle)
DEV/oracle-docker-images/OracleDatabase/dockerfiles> ./buildDockerImage.sh -v 11.2.0.2 -x
...

# After a successfull installation, you have the following message
  Oracle Database Docker Image for 'xe' version 11.2.0.2 is ready to be extended: 
    
    --> oracle/database:11.2.0.2-xe

  Build completed in 77 seconds.
  
```

# Run oracle xe
Beware that we use "adorsys" as system password. This shall not be done on a productive server. 
```
cd $DEV
DEV> docker-machine ls
NAME      ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER        ERRORS
oracle    *        virtualbox   Running   tcp://192.168.99.100:2376           v17.10.0-ce

DEV> cd keycloak-oracle
DEV/keycloak-oracle> docker run --name oracle --shm-size=1g -p 1521:1521 -p 8080:8080 -e ORACLE_PWD=adorsys -v /u01/app/oracle/oradata -v $PWD/setup:/u01/app/oracle/scripts/setup oracle/database:11.2.0.2-xe

# Beware our scrpit $DEV/keycloak-oracle/setup/init-oracle-xe.sql creates the user keyclaok with a password.

```

# Make oracle available under the domain name "oracle"

before you install keycloak, make sure you can reach the oracle docker host under the dns oracle.

```
DEV/keycloak-oracle> sudo vi /etc/hosts
#
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
##
127.0.0.1       localhost
255.255.255.255 broadcasthost
::1             localhost
~                    
# Add this line                         
192.168.99.100  oracle

# Save. And ping oracle to test.
DEV/keycloak-oracle> ping oracle
PING oracle (192.168.99.100): 56 data bytes
64 bytes from 192.168.99.100: icmp_seq=0 ttl=64 time=0.247 ms
64 bytes from 192.168.99.100: icmp_seq=1 ttl=64 time=0.261 ms

```

# Install Keycloak

```
DEV/keycloak-oracle> ./install-keycloak-with-oracle.sh

```

# Start keycloak

```
DEV/keycloak-oracle> cd keycloak-3.3.0.Final/bin
DEV/keycloak-oracle/keycloak-3.3.0.Final/bin> ./standalone.sh

# This line shows that the keycloak server issuccessfully started.
TS INFO  [org.jboss.as] (Controller Boot Thread) WFLYSRV0025: Keycloak 3.3.0.Final (WildFly Core 3.0.8.Final) started in 65275ms - Started 535 of 857 services (570 services are lazy, passive or on-demand)

```
# Setup keycloak admin password
Access keycloak for the first time and setup admin password using localhost:8080



