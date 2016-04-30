#
# Sniffle
#
USER=sniffle
GROUP=$USER
echo Configuring Sniffle...
mkdir -p /data/sniffle/db/ring
mkdir -p /data/sniffle/etc
mkdir -p /data/sniffle/log/sasl
chown -R $USER:$GROUP /data/sniffle

CONFFILE=/data/sniffle/etc/sniffle.conf
CONFEXAMPLE=/opt/local/fifo-sniffle/etc/sniffle.conf.example

if [ ! -f "${CONFFILE}" ]
then
    echo "Creating new configuration from example file."
    cp ${CONFEXAMPLE} ${CONFFILE}
    $SED -i bak -e "s/127.0.0.1/${IP}/g" ${CONFFILE}
else
        printf "${BOLD}*****************************************************************\nSniffle requires config changes. Read the Docs!\nhttps://docs.project-fifo.net/docs/upgrading-fifo#section-0-8-1\n*****************************************************************${NC}"
fi