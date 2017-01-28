#!/bin/bash

AWK=/usr/bin/awk
SED=/usr/bin/sed
CURL=/usr/bin/curl
RED='\033[0;31m'
GRN='\033[0;32m'
BOLD='\033[1m'
NC='\033[0m'

fail_if_error() {
    [ $1 != 0 ] && {
        unset PASSPHRASE
        printf "${RED}%s${NC}\n" "$2"
        exit 10
    }
}

echo Mounting filesystem ...
zfs set mountpoint=/data zones/$(sysinfo | json UUID)/data

echo Trying to IP guess configuration ...
IP=$(ifconfig net0 | grep inet | /usr/bin/awk '{print $2}')
