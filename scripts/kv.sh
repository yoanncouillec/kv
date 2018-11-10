#! /bin/sh


if [ "$1" = "start" ]
then 
    echo "$(date "+%F %T")|INFO|start kvd1"
    kvd --id kvd1

    echo "$(date "+%F %T")|INFO|start kvd2"
    kvd --id kvd2
    
    echo "$(date "+%F %T")|INFO|start kvr"
    kvr

    echo "$(date "+%F %T")|INFO|cluster started"
elif [ "$1" = "stop" ]
then
    echo "$(date "+%F %T")|INFO|stop cluster"
    kill `cat /var/run/kv/*.pid`
    echo "$(date "+%F %T")|INFO|cluster stopped"
else
    echo "$(date "+%F %T")|INFO|command unknown"
fi
