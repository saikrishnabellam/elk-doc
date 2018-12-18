#!/bin/bash

set -euo pipefail

cacert=/usr/share/kibana/config/ca/ca.crt
while [ ! -f $cacert ]
do
  sleep 2
done
ls -l $cacert

es_url=https://elasticsearch:9200


while [[ "$(curl -u "elastic:${ELASTIC_PASSWORD}" --cacert $cacert -s -o /dev/null -w '%{http_code}' $es_url)" != "200" ]]; do
    sleep 5
done

until curl -u "elastic:${ELASTIC_PASSWORD}" --cacert $cacert -s -H 'Content-Type:application/json' \
     -XPUT $es_url/_xpack/security/user/kibana/_password \
     -d "{\"password\": \"${ELASTIC_PASSWORD}\"}"
do
    sleep 2
    echo Retrying...
done


echo "=== CREATE Keystore ==="
if [ -f /config/kibana/kibana.keystore ]; then
    echo "Remove old kibana.keystore"
    rm /config/kibana/kibana.keystore
fi
/usr/share/kibana/bin/kibana-keystore create
echo "Setting elasticsearch.password: $ELASTIC_PASSWORD"
echo "$ELASTIC_PASSWORD" | /usr/share/kibana/bin/kibana-keystore add 'elasticsearch.password' -x

mv /usr/share/kibana/data/kibana.keystore /config/kibana/kibana.keystore
