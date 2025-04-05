#!/bin/zsh

postgres_pid=$(cat postgres_pid.txt)
jmsbroker_pid=$(cat jmsbroker_pid.txt)
oltp_pid=$(cat oltp_pid.txt)
redis_pid=$(cat redis_pid.txt)

echo -e "\nStop port forwarding with the following commands:"
echo -e "kill postgres"
kill $postgres_pid
echo -e "kill jmsbroker"
kill $jmsbroker_pid
echo -e "kill oltp"
kill $oltp_pid
echo -e "kill redis"
kill $redis_pid