#!/bin/bash
curl -v -H "Accept:application/json" -H "Content-type:application/json" -H "GEOGREP_PRINCIPAL:[id=11,ou=user,o=owner,o=org1,ou=services,dc=geogrep,dc=net]" -X$1 http://localhost:9091/location/api/$2 $3 $4

