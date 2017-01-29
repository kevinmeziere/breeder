#!/usr/bin/bash
VER="0.9.0"

cd /var/tmp

for PKG in aio howl snarl sniffle 
do
	curl -k https://raw.githubusercontent.com/project-fifo/breeder/${VER}/create-zone.sh?$(date -R | awk '{print $5}' | sed 's/\://g') | bash -s "${PKG}" "${VER}"  "DHCP"
done
