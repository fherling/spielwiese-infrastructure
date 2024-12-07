#!/bin/bash

#set -e
#set -x

kubectl config use-context minikube

export DOCKER_PW='4P1GgRFa/EH6DW2HD6yLrVb9bK06rApe'
error="N"


docker_pw="${DOCKER_PW}"


postgres_port="5432"

jmsbroker_port="61616"

oltp_http_port="4318"


kubectl create secret docker-registry acr-pull-secret \
    --namespace default \
    --docker-server=aepdockercontainerregistry.azurecr.io \
    --docker-username=aepdockercontainerregistry \
    --docker-password=$docker_pw




kubectl create configmap postgres --from-literal=POSTGRES_PASSWORD="pwd" --from-literal=POSTGRES_DB="db" --from-literal=POSTGRES_USER="user"
kubectl create -f postgres_deployment.yaml
kubectl expose deployment postgres --port=5432 --target-port=5432
echo ""

kubectl create -f artemis_deployment.yaml

kubectl create -f oltp_receiver_deployment.yaml
#kubectl apply -f https://raw.githubusercontent.com/open-telemetry/opentelemetry-collector/v0.115.1/examples/k8s/otel-config.yaml




echo -ne "waiting for postgres"
while [[ $(kubectl get pods -l app=postgres -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo -ne "." && sleep 1; done
echo ""
echo -ne "waiting for jmsbroker"
while [[ $(kubectl get pods -l app=activemq-artemis -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo -ne "." && sleep 1; done
echo ""

echo -ne "waiting for otlp-receiver"
while [[ $(kubectl get pods -l app=otlp-receiver -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo -ne "." && sleep 1; done
echo ""


echo -e "\nExposing ports\n"



kubectl port-forward service/postgres $postgres_port:5432 >/dev/null &
postgres_pid=$!
echo -e "Postgres is up and running under localhost:$postgres_port"
echo "Postgres PortForward PID: $postgres_pid"

kubectl port-forward service/activemq-artemis $jmsbroker_port:61616 >/dev/null &
jmsbroker_pid=$!
echo -e "Jmsbroker is up and running under localhost:$jmsbroker_port"
echo "Jmsbroker PortForward PID: $jmsbroker_pid"

kubectl port-forward service/otlp-receiver $oltp_http_port:4318 >/dev/null &
oltp_http_pid=$!
echo -e "Oltp receiver is up and running under localhost:$oltp_http_port"
echo "Oltp receiver PortForward PID: $oltp_http_pid"



echo "Press q to kill everything"
while : ; do
  read -n 1 k <&1
  if [[ $k = q ]]; then
    break
  fi
done

echo -e "\nRemoving everything"

kill $postgres_pid
kubectl delete service postgres
kubectl delete deployment postgres
kubectl delete configmap postgres  
kill $jmsbroker_pid
kubectl delete -f artemis_deployment.yaml

kill $oltp_http_pid
kubectl delete -f oltp_receiver_deployment.yaml


kubectl delete secret acr-pull-secret