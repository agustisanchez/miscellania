#!/bin/bash
export MAVEN_OPTS="-Xmx512m -XX:MaxPermSize=128m"
mvn -Dlogback.configurationFile="$LOGBACK_FILE" -Dspring.profiles.active=elasticsearch -DgeogrepConfigurationTarget=devtest -am -pl iam-rest verify > mvn.out 2>&1
