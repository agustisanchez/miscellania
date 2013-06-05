#!/bin/bash
export MAVEN_OPTS="-Xmx512m -XX:MaxPermSize=128m"
mvn -Pintegration -Dldap=on -DgeogrepConfigurationTarget=devtest -am -pl gp-iam-rest verify > mvn.out 2>&1
