## Begin user configurable variables

SSL_ORG="Canine Cloud Compute"
SSL_UNIT="Cloud Ops"
SSL_EMAIL="admin@fifo.cloud"

## End user configurable variables

LOCAL_INFO=$($CURL -s ipinfo.io)


CERT_SUBJ="
C=$(echo $LOCAL_INFO | json country)
ST=$(echo $LOCAL_INFO | json region)
O=$(echo $SSL_ORG)
localityName=$(echo $LOCAL_INFO | json city)
commonName=$IP
organizationalUnitName=$(echo $SSL_UNIT)
emailAddress=$(echo SSL_EMAIL)
"

#
# Howl
#

echo Configuring Howl...

USER=howl
GROUP=$USER


#DOMAIN="project-fifo.net"
CERTDIR="/data/fifo"
CERTPREFIX="fifo"
DAYS=3650

mkdir -p /data/howl/db/ring
mkdir -p /data/howl/etc
mkdir -p /data/howl/log/sasl
chown -R $USER:$GROUP /data/howl

## Certificate creation:
if [ ! -d $CERTDIR ]
then
    echo "Generating self signed SSL cert in $CERTDIR"

    export PASSPHRASE=$(head -c 128 /dev/random  | uuencode - | grep -v "^end" | tr "\n" "d")
    mkdir -p $CERTDIR

    openssl genrsa -des3 -out $CERTDIR/$CERTPREFIX.key -passout env:PASSPHRASE 2048
    fail_if_error $? "Could not create key."

    openssl req \
            -new \
            -batch \
            -subj "$(echo -n "$CERT_SUBJ" | tr "\n" "/")" \
            -key $CERTDIR/$CERTPREFIX.key \
            -out $CERTDIR/$CERTPREFIX.csr \
            -passin env:PASSPHRASE
    fail_if_error $? "Could not create certificate request."

    cp $CERTDIR/$CERTPREFIX.key $CERTDIR/$CERTPREFIX.key.org
    fail_if_error $? "Could not copy generated key."

    openssl rsa -in $CERTDIR/$CERTPREFIX.key.org -out $CERTDIR/$CERTPREFIX.key -passin env:PASSPHRASE
    fail_if_error $? "Could not remove passphrase from key."

    unset PASSPHRASE

    openssl x509 -req -days $DAYS -in $CERTDIR/$CERTPREFIX.csr -signkey $CERTDIR/$CERTPREFIX.key -out $CERTDIR/$CERTPREFIX.crt
    fail_if_error $? "Could not create x509 request."

    cat $CERTDIR/$CERTPREFIX.key $CERTDIR/$CERTPREFIX.crt > $CERTDIR/$CERTPREFIX.pem

    chgrp -R $GROUP $CERTDIR


fi

if [ -d /tmp/howl ]
then
    chown -R $USER:$GROUP /tmp/howl/
fi

CONFFILE=/data/howl/etc/howl.conf
CONFEXAMPLE=/opt/local/fifo-howl/etc/howl.conf.example

if [ ! -f "${CONFFILE}" ]
then
    echo "Creating new configuration from example file."
    cp ${CONFEXAMPLE} ${CONFFILE}
    $SED -i bak -e "s/127.0.0.1/${IP}/g" ${CONFFILE}
else
    printf "${BOLD}Please make sure you update your Howl config according to the update manual!${NC}\n"
fi
