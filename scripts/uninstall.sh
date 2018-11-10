#! /bin/sh

GROUPNAME=_kvgroup
USERNAME=_kvuser
CONFDIR=/etc/kv
BINDIR=/usr/local/bin
LOGDIR=/var/log/kv
RUNDIR=/var/run/kv

### DELETE GROUP

echo "$(date "+%F %T")|INFO|delete group: $GROUPNAME"
if dscl . -list /Groups | grep $GROUPNAME > /dev/null
then
    dscl . -delete /Groups/$GROUPNAME
    echo "$(date "+%F %T")|INFO|group deleted"
else 
    echo "$(date "+%F %T")|WARNING|group does not exists"
fi

### DELETE USER

echo "$(date "+%F %T")|INFO|delete user: $USERNAME"
if dscl . -list /Users | grep $USERNAME > /dev/null
then
    dscl . -delete /Users/$USERNAME
    echo "$(date "+%F %T")|INFO|user deleted"
else 
    echo "$(date "+%F %T")|WARNING|user does not exists"
fi

### DELETE CONFIGURATION DIRECTORY

echo "$(date "+%F %T")|INFO|delete configuration directory: $CONFDIR"
if [ ! -d "$CONFDIR" ]; then
    echo "$(date "+%F %T")|WARNING|configuration directory does not exists"
else    
    rm -r $CONFDIR
    echo "$(date "+%F %T")|INFO|configuration directory deleted"
fi

### DELETE LOG DIRECTORY

echo "$(date "+%F %T")|INFO|delete log directory: $LOGDIR"
if [ ! -d "$LOGDIR" ]; then
    echo "$(date "+%F %T")|WARNING|log directory does not exists"
else    
    rm -r $LOGDIR
    echo "$(date "+%F %T")|INFO|log directory deleted"
fi

### DELETE RUN DIRECTORY

echo "$(date "+%F %T")|INFO|delete run directory: $RUNDIR"
if [ ! -d "$RUNDIR" ]; then
    echo "$(date "+%F %T")|WARNING|run directory does not exists"
else    
    rm -r $RUNDIR
    echo "$(date "+%F %T")|INFO|run directory deleted"
fi

### DELETE BINARIES

rm $BINDIR/kvd
rm $BINDIR/kvr
rm $BINDIR/kv
