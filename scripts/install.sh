#! /bin/sh

GROUPNAME=_kvgroup
USERNAME=_kvuser
CONFDIR=/etc/kv
BINDIR=/usr/local/bin
LOGDIR=/var/log/kv
RUNDIR=/var/run/kv

### CREATE GROUP

echo "$(date "+%F %T")|INFO|create group: $GROUPNAME"
if dscl . -list /Groups | grep $GROUPNAME > /dev/null
then
    echo "$(date "+%F %T")|WARNING|group already exists"
else
    LASTGROUPID=`dscl . list /Groups PrimaryGroupID | tr -s ' ' | sort -n -t ' ' -k2,2 | tail -n 1 | cut -f2 -d" "`
    GROUPID=$((LASTGROUPID+1))
    dscl . -create /Groups/$GROUPNAME
    dscl . create /Groups/$GROUPNAME gid $GROUPID
    echo "$(date "+%F %T")|INFO|group created"
fi

## CREATE USER

echo "$(date "+%F %T")|INFO|create user: $USERNAME"
if dscl . -list /Users | grep $USERNAME > /dev/null
then
    echo "$(date "+%F %T")|WARNING|user already exists"
else
    LASTUID=`dscl . list /Users UniqueID | tr -s ' ' | sort -n -t ' ' -k2,2 | tail -n 1 | cut -f2 -d" "`
    MYUID=$((LASTUID+1))
    if ! dscl . -create /Users/$USERNAME
    then
	echo "$(date "+%F %T")|ERROR|cannot create user"
	exit 1
    fi
    if ! dscl . -create /Users/$USERNAME UserShell /usr/bin/false
    then
	echo "$(date "+%F %T")|ERROR|cannot create user shell"
	exit 1
    fi
    if ! dscl . -create /Users/$USERNAME UniqueID $MYUID
    then
	echo "$(date "+%F %T")|ERROR|cannot create user ID: $MYUID"
	exit 1
    fi
    if ! dscl . -create /Users/$USERNAME PrimaryGroupID $GROUPID
    then
	echo "$(date "+%F %T")|ERROR|cannot create user group IDL $GROUPID"
	exit 1
    fi
    echo "$(date "+%F %T")|INFO|user created"
fi

### CREATE CONFIGURATION DIRECTORY

echo "$(date "+%F %T")|INFO|create configuration directory: $CONFDIR"
if [ ! -d "$CONFDIR" ]; then
    mkdir $CONFDIR
    chown $USERNAME:$GROUPNAME $CONFDIR
    echo "$(date "+%F %T")|INFO|configuration directory created"
else    
    echo "$(date "+%F %T")|WARNING|configuration directory already exists"
fi

### CREATE LOG DIRECTORY

echo "$(date "+%F %T")|INFO|create log directory: $LOGDIR"
if [ ! -d "$LOGDIR" ]; then
    mkdir $LOGDIR
    chown $USERNAME:$GROUPNAME $LOGDIR
    echo "$(date "+%F %T")|INFO|log directory created"
else    
    echo "$(date "+%F %T")|WARNING|log directory already exists"
fi

### CREATE RUN DIRECTORY

echo "$(date "+%F %T")|INFO|create run directory: $RUNDIR"
if [ ! -d "$RUNDIR" ]; then
    mkdir $RUNDIR
    chown $USERNAME:$GROUPNAME $RUNDIR
    echo "$(date "+%F %T")|INFO|run directory created"
else    
    echo "$(date "+%F %T")|WARNING|run directory already exists"
fi

### COPY CONF

sudo -u $USERNAME cp conf/conf.json $CONFDIR

### COPY KVD

cp bin/kvd $BINDIR
chown $USERNAME:$GROUPNAME $BINDIR/kvd

### COPY KVR

cp bin/kvr $BINDIR
chown $USERNAME:$GROUPNAME $BINDIR/kvr

### COPY KV SCRIPT

cp scripts/kv.sh $BINDIR/kv
chown $USERNAME:$GROUPNAME $BINDIR/kv

### COPY KVC SCRIPT

cp bin/kvc $BINDIR
chown $USERNAME:$GROUPNAME $BINDIR/kvc

### COPY KVP SCRIPT

cp bin/kvp $BINDIR
chown $USERNAME:$GROUPNAME $BINDIR/kvp

### COPY SERVICE

cp scripts/com.kv.plist $HOME/Library/LaunchAgents/
launchctl load -w $HOME/Library/LaunchAgents/com.kv.plist
launchctl start -w $HOME/Library/LaunchAgents/com.kv.plist
