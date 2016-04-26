#!/bin/bash

AWK=/usr/bin/awk
SED=/usr/bin/sed
CURL=/usr/bin/curl

fail_if_error() {
    [ $1 != 0 ] && {
        unset PASSPHRASE
        echo $2
        exit 10
    }
}

echo Trying to guess configuration ...
IP=$(ifconfig net0 | grep inet | /usr/bin/awk '{print $2}')