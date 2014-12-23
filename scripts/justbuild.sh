#!/bin/sh -ex
if [[ -z "$HADOOP_VERSION"  ||  -z "$PIG_VERSION" || -z "$HIVE_VERSION" ]]; then
   echo "HADOOP_VERSION, PIG_VERSION and HIVE_VERSION must be explicitly set in the environment"
   exit 1
fi
mvn package assembly:single versions:set -DnewVersion=${ARTIFACT_VERSION} -DskipTests=true -Phadoop-2 -Dhadoop.version=${HADOOP_VERSION} -Dpig.version=${PIG_VERSION} -Dhive.version=${HIVE_VERSION}
