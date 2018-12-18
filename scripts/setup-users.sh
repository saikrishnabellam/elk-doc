#!/bin/bash

set -euo pipefail

cacert=/config/elasticsearch/ca/ca.crt
while [ ! -f $cacert ]
do
  sleep 2
done
ls -l $cacert

es_url=https://elastic:${ELASTIC_PASSWORD}@elasticsearch:9200
until curl -s --cacert $cacert $es_url -o /dev/null; do
    sleep 1
done


until curl --cacert $cacert -s -H 'Content-Type:application/json' \
     -XPUT $es_url/_xpack/security/user/kibana/_password \
     -d "{\"password\": \"${ELASTIC_PASSWORD}\"}"
do
    sleep 2
    echo Retrying...
done

until curl --cacert $cacert -s -H 'Content-Type:application/json' \
     -XPUT $es_url/_xpack/security/user/logstash_system/_password \
     -d "{\"password\": \"${ELASTIC_PASSWORD}\"}"
do
    sleep 2
    echo Retrying...
done
