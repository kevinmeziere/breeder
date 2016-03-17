PATH=/usr/local/sbin:/usr/local/bin:/opt/local/sbin:/opt/local/bin:/usr/sbin:/usr/bin:/sbin
export PATH


/usr/sbin/zfs set mountpoint=/data zones/$(sysinfo | json UUID)/data

/usr/bin/curl https://project-fifo.net/fifo.gpg > /root/fifo.gpg
/usr/bin/gpg --primary-keyring /opt/local/etc/gnupg/pkgsrc.gpg --import < /root/fifo.gpg
/usr/bin/echo "http://release.project-fifo.net/pkg/rel" >> /opt/local/etc/pkgin/repositories.conf
/opt/local/bin/pkgin -fy up
/opt/local/bin/pkgin -y install fifo-snarl
/opt/local/bin/pkgin -yf ug

/opt/local/bin/sm-prepare-image -y