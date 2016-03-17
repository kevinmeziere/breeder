zfs set mountpoint=/data zones/$(sysinfo | json UUID)/data


curl -O https://project-fifo.net/fifo.gpg
gpg --primary-keyring /opt/local/etc/gnupg/pkgsrc.gpg --import < fifo.gpg
echo "http://release.project-fifo.net/pkg/rel" >> /opt/local/etc/pkgin/repositories.conf
pkgin -fy up
pkgin -y install fifo-snarl
pkgin -yf ug

sm-zone-prep