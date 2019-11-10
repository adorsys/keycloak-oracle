export KEYCLOAK_VERSION=7.0.1

export JBOSS_HOME=keycloak-$KEYCLOAK_VERSION

if [ -d "$JBOSS_HOME" ]; then
  	rm -rf $JBOSS_HOME
   	sleep 1s	
fi


export KEYCLOAK_DIST=keycloak-$KEYCLOAK_VERSION.tar.gz
if [ ! -e "$KEYCLOAK_DIST" ]; then
   	echo " KEYCLOAK_DIST: $KEYCLOAK_DIST not yet downloaded. Dowloading dist"
   	curl -O https://downloads.jboss.org/keycloak/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz	
else
	echo " KEYCLOAK_DIST: $KEYCLOAK_DIST"
fi

# Unpack naked keycloak
tar xzf $KEYCLOAK_DIST

# Install oracle jdbc driver
mkdir -p $JBOSS_HOME/modules/system/layers/base/com/oracle/ojdbc6/main
cp OJDBC-Full/ojdbc6.jar $JBOSS_HOME/modules/system/layers/base/com/oracle/ojdbc6/main/
cp OJDBC-Full/ojdbc.policy $JBOSS_HOME/modules/system/layers/base/com/oracle/ojdbc6/main/
cp module.xml $JBOSS_HOME/modules/system/layers/base/com/oracle/ojdbc6/main/

$JBOSS_HOME/bin/jboss-cli.sh --file=standalone-configuration.cli




