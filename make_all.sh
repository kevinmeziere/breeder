#!/usr/bin/bash
VER="0.8.2"

cd /var/tmp
curl -s -k -O https://raw.githubusercontent.com/kevinmeziere/breeder/${VER}/s3.sh
chmod +x s3.sh

curl -s -k -O https://raw.githubusercontent.com/kevinmeziere/breeder/${VER}/dsindex.sh
chmod +x dsindex.sh

for PKG in aio howl snarl sniffle 
do
	curl -k https://raw.githubusercontent.com/kevinmeziere/breeder/${VER}/create-zone.sh?$(date -R | awk '{print $5}' | sed 's/\://g') | bash -s "${PKG}" "${VER}"  "DHCP"
	UUID=$(json -f "fifo-$PKG-$VER.imgmanifest" uuid)
	#TODO: S3 No Longer used. scp to server instead!
	./s3.sh fifo-$PKG-$VER.imgmanifest fifo-$PKG-$VER.imgmanifest "application/xml"
	./s3.sh fifo-$PKG-$VER.zfs.bz2 ${UUID}/file.bz2 "application/x-bzip2"
done