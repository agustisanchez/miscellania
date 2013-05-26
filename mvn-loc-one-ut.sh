#!/bin/bash
export MAVEN_OPTS="-Xmx512m -XX:MaxPermSize=128m"
if [ $# -lt  1 ]
then
   echo "Not enough arguments"
   exit 1
fi
mvn -Pintegration -DgeogrepConfigurationTarget=devtest -DindexerSearchTarget=devtest -DfailIfNoTests=false -am -pl gp-location-rest -Dtest=$1 test > mvn.out 2>&1

