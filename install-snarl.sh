PATH=/usr/local/sbin:/usr/local/bin:/opt/local/sbin:/opt/local/bin:/usr/sbin:/usr/bin:/sbin
export PATH


zfs set mountpoint=/data zones/$(sysinfo | json UUID)/data

curl https://project-fifo.net/fifo.gpg > /root/fifo.gpg
gpg --primary-keyring /opt/local/etc/gnupg/pkgsrc.gpg --import < /root/fifo.gpg
echo "http://release.project-fifo.net/pkg/15.4.1/rel" >> /opt/local/etc/pkgin/repositories.conf
pkgin -fy up
pkgin -y install fifo-snarl
pkgin -yf ug
pkgin clean

svcadm enable epmd

awk '!/metadata\.sock/' /opt/local/bin/sm-prepare-image > /opt/local/bin/sm-prepare-image-mod
chmod +x /opt/local/bin/sm-prepare-image-mod
/opt/local/bin/sm-prepare-image-mod -y
