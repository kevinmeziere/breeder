BUCKET="datasets.project-fifo.net"

COLLECTOR="["
FIRST=true

while read MANIFEST; do
	MJSON=$(curl -s http://$BUCKET.s3.amazonaws.com/$MANIFEST)
	if (echo -n $MJSON | json --validate -q) ; then
		if [ "$FIRST" = false ] ; then
    	COLLECTOR=$COLLECTOR$','
		fi
		COLLECTOR=$COLLECTOR$'\n'$MJSON
		FIRST=false
	fi
done < <(curl -s http://$BUCKET.s3.amazonaws.com | awk  '{print $0}' RS='Contents' | sed -n 's:.*<Key>\(.*\.imgmanifest\)</Key>.*:\1:p')

COLLECTOR=${COLLECTOR}$'\n]'

echo -e $COLLECTOR