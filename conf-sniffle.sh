#
# Sniffle
#
USER=sniffle
GROUP=$USER
echo Configuring Sniffle
echo Creating directories ...
mkdir -p /data/sniffle/db/ring
mkdir -p /data/sniffle/etc
mkdir -p /data/sniffle/log/sasl
chown -R $USER:$GROUP /data/sniffle

CONFFILE=/data/sniffle/etc/sniffle.conf
cp /opt/local/fifo-sniffle/etc/sniffle.conf.example ${CONFFILE}.example
if [ ! -f "${CONFFILE}" ]
then
    echo "Creating new configuration from example file."
    cp ${CONFFILE}.example ${CONFFILE}
    $SED -i bak -e "s/127.0.0.1/${IP}/g" ${CONFFILE}
else
    echo "Please make sure you update your config according to the update manual!"
    #/opt/local/fifo-sniffle/share/update_config.sh ${CONFFILE}.example ${CONFFILE} > ${CONFFILE}.new &&
    #    mv ${CONFFILE} ${CONFFILE}.old &&
    #    mv ${CONFFILE}.new ${CONFFILE}
fi