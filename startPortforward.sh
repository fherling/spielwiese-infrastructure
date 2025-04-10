#!/bin/zsh

kubectl wait pod --all --for=condition=Ready --namespace=spielwiese --timeout=600s


# Expose ports
kubectl port-forward --namespace spielwiese service/postgres 5432:5432 >/dev/null &
postgres_pid=$!
echo $postgres_pid > postgres_pid.txt
echo "Postgres PortForward PID: $postgres_pid"

kubectl port-forward --namespace spielwiese service/activemq-artemis 61616:61616 >/dev/null &
jmsbroker_pid=$!
echo $jmsbroker_pid > jmsbroker_pid.txt
echo "Jmsbroker PortForward PID: $jmsbroker_pid"

kubectl port-forward --namespace spielwiese service/jaeger 4318:4318 >/dev/null &
oltp_pid=$!
echo $oltp_pid > oltp_pid.txt
echo "OLTP PortForward PID: $oltp_pid"

kubectl port-forward --namespace spielwiese service/redis 6379:6379 >/dev/null &
redis_pid=$!
echo $redis_pid > redis_pid.txt
echo "redis PortForward PID: $redis_pid"

