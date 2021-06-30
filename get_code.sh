#!/usr/bin/env bash

CLIENT_ID="<your-client-id>"
CLIENT_SECRET="<your-client-secret>"
echo "Please visit this url and provide the authorization code: https://accounts.google.com/o/oauth2/auth?hl=en&response_type=code&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2$
read -e -p "Your authorization code: " AUTHORIZATION_CODE
REFRESH_TOKEN_RESPONSE=$(curl -s --location --request POST 'https://oauth2.googleapis.com/token' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode "code=${AUTHORIZATION_CODE}" \
--data-urlencode "client_id=${CLIENT_ID}" \
--data-urlencode "client_secret=${CLIENT_SECRET}" \
--data-urlencode 'redirect_uri=urn:ietf:wg:oauth:2.0:oob' \
--data-urlencode 'grant_type=authorization_code' | tr '\n' ' ')

REGEX=$(echo \'${REFRESH_TOKEN_RESPONSE}\')
REFRESH_TOKEN=$(perl -pe 's/.+"refresh_token": "([^"]+)".+/$1/' <<< ${REGEX})

mkdir -pv /etc/gahfy-app
echo $REFRESH_TOKEN > /etc/gahfy-app/refresh-token.txt
