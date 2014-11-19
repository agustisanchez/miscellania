#!/bin/bash
export MAVEN_OPTS="-Xmx512m -XX:MaxPermSize=128m"
mvn -Pintegration -Dlogback.configurationFile="$LOGBACK_FILE" -DgeogrepConfigurationTarget=devtest -am -pl indextool-war verify > mvn.out 2>&1
