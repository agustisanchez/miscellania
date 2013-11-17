#!/bin/bash
export MAVEN_OPTS="-Xmx512m -XX:MaxPermSize=128m"
mvn -Dlogback.configurationFile="$LOGBACK_FILE" -DgeogrepConfigurationTarget=devtest verify > mvn.out 2>&1

