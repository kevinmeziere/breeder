BUCKET="datasets.project-fifo.net"

COLLECTOR="["
FIRST=true


manifest_by_uuid(){
	MANIFEST=$2
	MJSON=$1
	UUID=$(echo -e $MANIFEST | json UUID)
	if ! curl -X HEAD -s -I -f http://$BUCKET/images/$UUID ; then
		TMP=mktemp
		CDate=$(curl -X HEAD -s -I http://$BUCKET.s3.amazonaws.com/$MANIFEST | grep "Last-Modified" | awk '{printf $5"-%02d-"$3"T"$6".000Z", (match("JanFebMarAprMayJunJulAugSepOctNovDec",$4)+2)/3}')
		echo -n $MJSON | json -e 'this.state="active", this.disabled=false, this.public=true, this.published_at="'${CDate}'"' > $TMP
		
	fi

}


while read MANIFEST; do
	MJSON=$(curl -s http://$BUCKET.s3.amazonaws.com/$MANIFEST)
	if (echo -n $MJSON | json --validate -q) ; then
		if [ "$FIRST" = false ] ; then
    	COLLECTOR=$COLLECTOR$','
		fi
		CDate=$(curl -X HEAD -s -I http://$BUCKET.s3.amazonaws.com/$MANIFEST | grep "Last-Modified" | awk '{printf $5"-%02d-"$3"T"$6".000Z", (match("JanFebMarAprMayJunJulAugSepOctNovDec",$4)+2)/3}')
		COLLECTOR=$COLLECTOR$'\n'$(echo -n $MJSON | json -e 'this.state="active", this.disabled=false, this.public=true, this.published_at="'${CDate}'"')
		FIRST=false
	fi
done < <(curl -s http://$BUCKET.s3.amazonaws.com | awk  '{print $0}' RS='Contents' | sed -n 's:.*<Key>\(.*\.imgmanifest\)</Key>.*:\1:p')

COLLECTOR=${COLLECTOR}$'\n]'

echo -e $COLLECTOR

