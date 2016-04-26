PATH=/usr/local/sbin:/usr/local/bin:/opt/local/sbin:/opt/local/bin:/usr/sbin:/usr/bin:/sbin
export PATH


zfs set mountpoint=/data zones/$(sysinfo | json UUID)/data

curl https://project-fifo.net/fifo.gpg > /root/fifo.gpg
gpg --primary-keyring /opt/local/etc/gnupg/pkgsrc.gpg --import < /root/fifo.gpg
echo "http://release.project-fifo.net/pkg/rel" >> /opt/local/etc/pkgin/repositories.conf
pkgin -fy up
pkgin -y install python27  py27-xml fifo-howl fifo-cerberus
pkgin -yf ug
pkgin clean

svcadm enable epmd

sm-prepare-image -y