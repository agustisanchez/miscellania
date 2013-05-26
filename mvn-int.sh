#!/bin/bash
export MAVEN_OPTS="-Xmx512m -XX:MaxPermSize=128m"
mvn -Pintegration -DgeogrepConfigurationTarget=devtest -DindexerSearchTarget=devtest verify > mvn.out 2>&1

