#!/bin/sh -ex
if [[ -z "$HADOOP_VERSION"  ||  -z "$PIG_VERSION" || -z "$HIVE_VERSION" || -z "$SQOOP_VERSION" ]]; then
   echo "HADOOP_VERSION, PIG_VERSION and HIVE_VERSION must be explicitly set in the environment"
   exit 1
fi

# See https://issues.apache.org/jira/browse/CALCITE-756 . We are installing untrusted code just to build oozie->hive for now.
# WE SHOULD REMOVE THIS ASAP.
wget http://conjars.org/repo/org/pentaho/pentaho-aggdesigner-algorithm/5.1.5-jhyde/pentaho-aggdesigner-algorithm-5.1.5-jhyde.jar

# Install these untrusted artifacts in our local maven cache so that we can build hive.
mvn install:install-file -Dfile=pentaho-aggdesigner-algorithm-5.1.5-jhyde.jar -DgroupId=org.pentaho -DartifactId=pentaho-aggdesigner-algorithm -Dpackaging=jar -Dversion=5.1.5-jhyde

mvn install assembly:single versions:set -DnewVersion=${ARTIFACT_VERSION} -Puber -DskipTests=true -Phadoop-2 -Dhadoop.version=${HADOOP_VERSION} -Dpig.version=${PIG_VERSION} -Dhive.version=${HIVE_VERSION} -Dsqoop.version=${SQOOP_VERSION}

# Discover the path of the local maven cache
MAVEN_LOCAL_REPO=`mvn help:evaluate -Dexpression=settings.localRepository | egrep -v '[INFO]|Download'`

# Remove the untrusted artifacts from this node's local maven repo soon as we have built hive
find $MAVEN_LOCAL_REPO -name 'pentaho-aggdesigner*' -type d | xargs rm -rf

