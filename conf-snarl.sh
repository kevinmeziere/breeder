#
# Snarl
#
USER=snarl
GROUP=$USER
echo Configuring Snarl...
mkdir -p /data/snarl/db/ring
mkdir -p /data/snarl/etc
mkdir -p /data/snarl/log/sasl
chown -R $USER:$GROUP /data/snarl

CONFFILE=/data/snarl/etc/snarl.conf
CONFEXAMPLE=/opt/local/fifo-snarl/etc/snarl.conf.example

if [ ! -f "${CONFFILE}" ]
then
    echo "Creating new configuration from example file."
    cp ${CONFEXAMPLE} ${CONFFILE}
    $SED -i bak -e "s/127.0.0.1/${IP}/g" ${CONFFILE}
else
    printf "${BOLD}Please make sure you update your Snarl config according to the update manual!${NC}\n"
fi
