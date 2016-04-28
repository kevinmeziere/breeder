cd /opt/local/share/htdocs

# Import Pending Datasets
for Manifest in $(ls *.imgmanifest); do
	set -e
	File=${Manifest%.*}.zfs.bz2
	UUID=$(json -f $Manifest uuid)
	mkdir images/$UUID
#	mv $Manifest images/$UUID/index.html
	CDate=$(date +%Y-%m-%dT%H:%M:%S.000Z -d @$(stat -c %Y $Manifest))
	json -f $Manifest -e 'this.state="active", this.disabled=false, this.public=true, this.published_at="'${CDate}'"' > images/$UUID/index.html
	mv $Manifest ${Manifest%.*}.imported
	mv $File images/$UUID/file
	set +e
done



# Create Dataset listings
COLLECTOR="["
FIRST=true

for Manifest in $(ls -r images/*/index.html); do
	set -e
	if json --validate -q -f $Manifest ; then
		if [ "$FIRST" = false ] ; then
    	COLLECTOR=$COLLECTOR$','
		fi
		CDate=$(date +%Y-%m-%dT%H:%M:%S.000Z -d @$(stat -c %Y $Manifest))
		COLLECTOR=$COLLECTOR$'\n'$(json -f $Manifest -e 'this.state="active", this.disabled=false, this.public=true, this.published_at="'${CDate}'"')
		FIRST=false
	fi
	set +e
done
COLLECTOR=${COLLECTOR}$'\n]'
echo -e $COLLECTOR | json > images/index.html