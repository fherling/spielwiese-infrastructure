#!/bin/bash

init()
{
KEYCLOAK_URL="http://keycloak.local/auth"
REDIRECT_URL="http://localhost:8088"
USERNAME="dummy2"
REALM="spielwiese-realm"
CLIENTID="spielwiese-client"
}

decode() {
  jq -R 'split(".") | .[1] | @base64d | fromjson' <<< $1
}
read -rp "password: " -s PASSWORD

echo " "


init

COOKIE="`pwd`/cookie.jar"

curl -sSL  --get --cookie "$COOKIE" --cookie-jar "$COOKIE" \
  --data-urlencode "client_id=${CLIENTID}" \
  --data-urlencode "redirect_uri=${REDIRECT_URL}" \
  --data-urlencode "scope=openid" \
  --data-urlencode "response_type=code" \
  "$KEYCLOAK_URL/realms/$REALM/protocol/openid-connect/auth" | pup "form#kc-form-login attr{action}"

AUTHENTICATE_URL=$(curl -sSL  --get --cookie "$COOKIE" --cookie-jar "$COOKIE" \
  --data-urlencode "client_id=${CLIENTID}" \
  --data-urlencode "redirect_uri=${REDIRECT_URL}" \
  --data-urlencode "scope=openid" \
  --data-urlencode "response_type=code" \
  "$KEYCLOAK_URL/realms/$REALM/protocol/openid-connect/auth" | pup "form#kc-form-login attr{action}")




AUTHENTICATE_URL=`echo $AUTHENTICATE_URL  | sed -e 's/\&amp;/\&/g'`

echo "Sending Username Password to following authentication URL of keycloak : $AUTHENTICATE_URL"

echo " "

CODE_URL=$(curl -sS --cookie "$COOKIE" --cookie-jar "$COOKIE" \
  --data-urlencode "username=$USERNAME" \
  --data-urlencode "password=$PASSWORD" \
  --write-out "%{REDIRECT_URL}" \
  "$AUTHENTICATE_URL")

echo "Following URL with code received from Keycloak : $CODE_URL"
echo " "
 
code=`echo $CODE_URL | awk -F "code=" '{print $2}' | awk '{print $1}'`

echo "Extracted code : $code"
echo " "
echo " "

echo "Sending code=$code to Keycloak to receive Access token"
echo " "

ACCESS_TOKEN=$(curl -sS --cookie "$COOKIE" --cookie-jar "$COOKIE" \
  --data-urlencode "client_id=$CLIENTID" \
  --data-urlencode "redirect_uri=$REDIRECT_URL" \
  --data-urlencode "code=$code" \
  --data-urlencode "grant_type=authorization_code" \
  "$KEYCLOAK_URL/realms/$REALM/protocol/openid-connect/token" \
  | jq -r ".access_token")

#echo "access token : $ACCESS_TOKEN" 
echo " "

echo "Decoded Access Token: "
decode $ACCESS_TOKEN

rm $COOKIE