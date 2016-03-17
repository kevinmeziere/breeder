# To use:
# curl -k https://raw.githubusercontent.com/kevinmeziere/breeder/master/create-zone.sh | bash -s "10.10.10.10" "10.10.10.1" "255.255.255.0"
#

InstallerZoneIP=$(echo $1 | tr '[:lower:]' '[:upper:]')
InstallerZoneGW=$2
InstallerZoneMASK=$3


imgadm update
mkdir /opt/images
mkdir /opt/zone_definitions
imgadm import 1bd84670-055a-11e5-aaa2-0346bb21d5a1
wget --no-check-certificate -O /opt/zone_definitions/ds_builder.json.tmp https://raw.githubusercontent.com/kevinmeziere/breeder/master/create-zone-def.template?$RANDOM

if [ "$InstallerZoneIP" = "DHCP" ]
then
  sed "s/{{IP}}/dhcp/g;/{{GW}}/d;/{{MASK}}/d" /opt/zone_definitions/ds_builder.json.tmp > /opt/zone_definitions/ds_builder.json
else
  sed "s/{{IP}}/$InstallerZoneIP/g;s/{{GW}}/$InstallerZoneGW/g;s/{{MASK}}/$InstallerZoneMASK/g" /opt/zone_definitions/ds_builder.json.tmp > /opt/zone_definitions/ds_builder.json
fi

echo "Creating temporary vm for installation..."

VMUUID=$((vmadm create -f /opt/zone_definitions/ds_builder.json) 2>&1 | grep "Successfully" | awk '{print $4}')
if [ -z "$VMUUID" ]
then
	echo "Unable to create installer VM."
	exit 1
fi

echo "Successfully created VM: $VMUUID"

echo -n "Sleeping for zone to finish install"

x=0

while [ $(vmadm get $VMUUID | json state) != "stopped"]
do
	if [ $x -ge 3 ]
	then
		x=0
		echo -en "\rSleeping for zone to finish install"
	fi

	sleep 2
	echo -n "."
	((x++))
done
echo ""
echo "Zone install done."
