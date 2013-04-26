#!/bin/bash
curl -v -H "Accept:application/json" -H "Content-type:application/json" -X$1 http://localhost:9091/location/api/$2 $3 $4

