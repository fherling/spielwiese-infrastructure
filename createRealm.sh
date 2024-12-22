bin/kcadm.sh  config credentials --server http://localhost:8080 --realm master --user admin --password pwd

bin/kcadm.sh create users --realm=master -s username=test -s enabled=true -s email=test@gmail.com -s emailVerified=true --server http://localhost:8080 

bin/kcadm.sh set-password --realm=master --username test --new-password password --server http://localhost:8080 