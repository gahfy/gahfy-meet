#!/usr/bin/env bash

API_KEY="<your-api-key>"
CLIENT_ID="<your-client-id>"
CLIENT_SECRET="<your-client-secret>"
REFRESH_TOKEN=$(cat /etc/gahfy-app/refresh-token.txt)

TOKEN_RESULT=$(curl -s --location --request POST 'https://oauth2.googleapis.com/token' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode "client_id=${CLIENT_ID}" \
--data-urlencode "client_secret=${CLIENT_SECRET}" \
--data-urlencode 'grant_type=refresh_token' \
--data-urlencode "refresh_token=${REFRESH_TOKEN}" | tr '\n' ' ')

REGEX=$(echo \'${TOKEN_RESULT}\')

ACCESS_TOKEN=$(perl -pe 's/.+"access_token": "([^"]+)".+/$1/' <<< ${REGEX})

VIDEO_FILE=$(ls $1/*.mp4)
VIDEO_NAME=$(ls $1/*.mp4 | perl -pe 's#/([a-z0-9A-Z]+/)+([^/]+)_[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}.mp4#$2#')

curl --verbose --location --request POST "https://www.googleapis.com/upload/youtube/v3/videos?uploadType=resumable&part=snippet&part=status&key=${API_KEY}" \
--header "Authorization: Bearer ${ACCESS_TOKEN}" \
--header 'Content-Type: application/json' \
--data-raw "{
    \"snippet\": {
        \"title\": \"${VIDEO_NAME}\",
        \"description\": \"Uploaded from Gahfy Meeting\",
        \"tags\": []
    },
    \"status\": {
        \"privacyStatus\": \"unlisted\"
    }
}" > /tmp/tmp_upload.txt 2>&1

VIDEO_LOCATION=$(cat /tmp/tmp_upload.txt | tr '\n' ' ' | perl -pe 's/.+location: ([^ ]+).+/$1/')
VIDEO_LOCATION=${VIDEO_LOCATION%$'\r'}

rm /tmp/tmp_upload.txt

curl --location --request POST "${VIDEO_LOCATION}" --header 'Content-Type: video/mp4' --data-binary "@${VIDEO_FILE}"

# This line will remove the folder created by Jibri
# As I consider my script to still be a beta version, I don't remove it for now
# rm -r $1
