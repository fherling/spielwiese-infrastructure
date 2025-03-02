#!/bin/zsh

#bin/kcadm.sh  config credentials --server http://localhost:8080 --realm master --user admin --password pwd

#bin/kcadm.sh create users --realm=master -s username=test -s enabled=true -s email=test@gmail.com -s emailVerified=true --server http://localhost:8080 

#bin/kcadm.sh set-password --realm=master --username test --new-password password --server http://localhost:8080 




curl --request POST \
  --url http://keycloak.local/realms/master/protocol/openid-connect/token \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data 'grant_type=password&client_id=admin-cli&username=admin&password=pwd'


curl --request POST \
  --url http://keycloak.local/admin/realms \
  --header 'Authorization: Bearer <access_token>' \
  --header 'Content-Type: application/json' \
  --data '{
    "id": "spielwiese-realm",
    "realm": "spielwiese-realm",
    "enabled": true
  }'


curl --request POST \
  --url http://keycloak.local/admin/realms/myrealm/clients \
  --header 'Authorization: Bearer <access_token>' \
  --header 'Content-Type: application/json' \
  --data '{
    "clientId": "spielwiese-client",
    "protocol": "openid-connect",
    "publicClient": true,
    "redirectUris": ["http://app.local:8088/*", "http://localhost:8088/*"],
    "directAccessGrantsEnabled": true,
    "standardFlowEnabled": true
  }'

curl --request POST \
    --url http://keycloak.local/admin/realms/spielwiese-realm/users \
    --header 'Authorization: Bearer {{bearertoken}}' \
    --header 'Content-Type: application/json' \
    --data '{
        "username": "newuser",
        "enabled": true,
        "email": "newuser@example.com",
        "emailVerified": true,
        "requiredActions": [],
        "credentials": [{
            "type": "password",
            "value": "newpassword",
            "temporary": false
        }]
    }'

    curl --request POST \
        --url {{idp_url}}/admin/realms/{{realm_name}}/roles \
        --header 'Authorization: Bearer <access_token>' \
        --header 'Content-Type: application/json' \
        --data '{
            "name": "appuser",
            "composite": false,
            "clientRole": false,
            "containerId": "{{realm_name}}"
        }'

        curl --request POST \
            --url http://keycloak.local/admin/realms/spielwiese-realm/users/{{user_id}}/role-mappings/realm \
            --header 'Authorization: Bearer <access_token>' \
            --header 'Content-Type: application/json' \
            --data '[
                {
                    "id": "{{role_id}}",
                    "name": "appuser"
                }
            ]'


