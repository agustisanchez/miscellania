#!/bin/bash
export MAVEN_OPTS="-Xmx512m -XX:MaxPermSize=128m"
mvn -Pintegration -Dlogback.configurationFile="$LOGBACK_FILE" -DgeogrepConfigurationTarget=devtest -am -pl geo-rest verify > mvn.out 2>&1
