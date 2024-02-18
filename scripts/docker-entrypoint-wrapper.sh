#!/usr/bin/env bash

set -e

# If the DEBUG variable exists, the commands and their arguments will be displayed as they are executed.
[ -n "${DEBUG:-}" ] && set -x

# load dynamic environment variables
export REPMGR_BASE=${REPMGR_BASE:-"/etc/repmgr"}
export REPMGR_PATH=${REPMGR_PATH:-"$REPMGR_BASE/$REPMGR_HOST"}
export REPMGR_SSH_PORT=${REPMGR_SSH_PORT:-"2222"}

echo "Running [docker-entrypoint-wrapper.sh]..."

export SSH_PORT=$(cat /etc/ssh/sshd_config | grep $REPMGR_SSH_PORT)

if [[ -z "$SSH_PORT" ]]; then
    echo "Port $REPMGR_SSH_PORT" >> /etc/ssh/sshd_config
fi

nohup bash -c "sleep 1 && service ssh start" &


if [[ -f "$REPMGR_PATH/.REPMGR_RUNTIME_ENV" ]]; then

    source "$REPMGR_PATH/.REPMGR_RUNTIME_ENV"

   if [[ -f "$REPMGR_BASE/$REPMGR_MODE.lock" ]]; then
        if [[ $(cat "$REPMGR_BASE/$REPMGR_MODE.lock") == $REPMGR_NODE_ID ]]; then
            su postgres -c "nohup /usr/local/bin/repmgr-register.sh -m $REPMGR_MODE -k true &"
        else
            echo "Running repmgr-rejoin [$REPMGR_REJOIN_CONNINFO]..."
            su postgres -c "repmgr-rejoin.sh -d $REPMGR_REJOIN_CONNINFO"
            su postgres -c "pg_ctl stop"
        fi
    fi
fi

export PSQL_ARGS="$@"
if [[ -z "$PSQL_ARGS" ]]; then
    PSQL_ARGS=postgres
fi

/usr/local/bin/docker-entrypoint.sh $PSQL_ARGS && /usr/local/bin/repmgr-switchover.sh -validate