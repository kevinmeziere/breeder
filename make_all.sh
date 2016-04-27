VER="0.8.0"

cd /var/tmp
curl -k -O https://raw.githubusercontent.com/kevinmeziere/breeder/${VER}/s3.sh
chmod +x s3.sh

curl -k -O https://raw.githubusercontent.com/kevinmeziere/breeder/${VER}/dsindex.sh
chmod +x dsindex.sh

for PKG in aio howl snarl sniffle do
	curl -k https://raw.githubusercontent.com/kevinmeziere/breeder/${VER}/create-zone.sh?$(date -R | awk '{print $5}' | sed 's/\://g') | bash -s "${PKG}" "${VER}"  "DHCP"
	UUID=$(json -f fifo-${PKG}-${VER}.imgmanifest uuid)
	./s3.sh fifo-aio-0.8.0.imgmanifest fifo-aio-0.8.0.imgmanifest "application/xml"
	./s3.sh fifo-aio-0.8.0.zfs.bz2 ${UUID}/file.bz2 "application/x-bzip2"
done

./dsindex.sh > dsindex
./s3.sh dsindex dsindex "application/json"