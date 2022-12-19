#!/bin/sh
# Shellchecked: All good

VALIDATION_MARKER=/var/etcd/data/validation_marker

# Add self-signed CA to list of root CA-certificates
if [ "${ENABLE_TLS}" = 'true' ]; then
    if ! cat /var/etcd/ssl/client/ca/*.crt >> /etc/ssl/certs/ca-certificates.crt; then
        echo "failed to update root certificate list"
        exit 1
    fi
fi

# shellcheck disable=SC2064
trap_and_propagate() {
    PID=$1
    shift
    for sig in "$@"; do
        trap "kill -$sig $PID" "$sig"
    done
}

start_managed_etcd(){
    rm -rf $VALIDATION_MARKER
    CONFIG_FILE=/etc/etcd.conf.yaml
    curl "$BACKUP_ENDPOINT/config" -o $CONFIG_FILE
    minimumsize=50
    actualsize=$(wc -c <$CONFIG_FILE)
    if [ "${actualsize}" -le "${minimumsize}" ]; then
        echo "downloaded config file size is less than $(minimumsize) bytes"
        exit 1
    fi
    etcd --config-file $CONFIG_FILE &
    ETCDPID=$!
    trap_and_propagate $ETCDPID INT TERM
    wait $ETCDPID
    RET=$?
    echo $RET > $VALIDATION_MARKER
    exit $RET
}

check_and_start_etcd(){
    while true; do
        wget "$BACKUP_ENDPOINT/initialization/status" -S -O status
        STATUS=$(cat status)
        case $STATUS in
            "New")
                wget "$BACKUP_ENDPOINT/initialization/start?mode=$1$FAIL_BELOW_REVISION_PARAMETER" -S -O - ;;
            "Progress")
                sleep 1
                continue ;;
            "Failed")
                sleep 1
                continue ;;
            "Successful")
                echo "Bootstrap preprocessing end time: $(date)"
                start_managed_etcd
                break ;;
            *)
                sleep 1 ;;
        esac
    done
}

echo "Bootstrap preprocessing start time: $(date)"
if [ ! -f $VALIDATION_MARKER ]; then
    echo "No $VALIDATION_MARKER file. Perform complete initialization routine and start etcd."
    check_and_start_etcd full
else
    echo "$VALIDATION_MARKER file present. Check return status and decide on initialization"
    run_status=$(cat $VALIDATION_MARKER)
    echo "$VALIDATION_MARKER content: $run_status"
    if [ "${run_status}" = '143' ] || [ "${run_status}" = '130' ] || [ "${run_status}" = '0' ]; then
        echo "Requesting sidecar to perform sanity validation"
        check_and_start_etcd sanity
    else
        echo "Requesting sidecar to perform full validation"
        check_and_start_etcd full
    fi
fi
