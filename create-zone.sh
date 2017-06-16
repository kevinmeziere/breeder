# To use:
# curl -k https://raw.githubusercontent.com/project-fifo/breeder/master/create-zone.sh | bash -s "aio" "0.9.2" "10.10.10.10" "10.10.10.1" "255.255.255.0"
# curl -k https://raw.githubusercontent.com/project-fifo/breeder/master/create-zone.sh?$(date -R | awk '{print $5}' | sed 's/\://g') | bash -s "aio" "0.9.2"  "DHCP"
# cleanup with: vmadm list | grep breeder | awk {'print $1'} | xargs -n 1 vmadm delete

set -e

PackageName=$1
PackageVersion=$2
InstallerZoneIP=$(echo $3 | tr '[:lower:]' '[:upper:]')
InstallerZoneGW=$4
InstallerZoneMASK=$5


imgadm update
[ -d /opt/images ] || mkdir /opt/images
[ -d /opt/zone_definitions ] || mkdir /opt/zone_definitions
imgadm import e1faace4-e19b-11e5-928b-83849e2fd94a
wget --no-check-certificate -O /opt/zone_definitions/ds_builder.json.tmp https://raw.githubusercontent.com/project-fifo/breeder/0.9.2/create-zone-def.template?$RANDOM

if [ "$InstallerZoneIP" = "DHCP" ]
then
  sed "s/{{PACKAGENAME}}/$PackageName/g;s/{{PACKAGEVER}}/$PackageVersion/g;s/{{IP}}/dhcp/g;/{{GW}}/d;/{{MASK}}/d" /opt/zone_definitions/ds_builder.json.tmp > /opt/zone_definitions/ds_builder.json
else
  sed "s/{{PACKAGENAME}}/$PackageName/g;s/{{PACKAGEVER}}/$PackageVersion/g;s/{{IP}}/$InstallerZoneIP/g;s/{{GW}}/$InstallerZoneGW/g;s/{{MASK}}/$InstallerZoneMASK/g" /opt/zone_definitions/ds_builder.json.tmp > /opt/zone_definitions/ds_builder.json
fi

echo "Creating temporary vm for installation..."

VMUUID=$((vmadm create -f /opt/zone_definitions/ds_builder.json) 2>&1 | grep "Successfully" | awk '{print $4}')
if [ -z "$VMUUID" ]
then
	echo "Unable to create installer VM."
	exit 1
fi

echo "Successfully created VM: $VMUUID"

echo -en "Sleeping for zone to finish install"

x=0

set +e

while [ $(vmadm get $VMUUID | json state) != "stopped" ]
do
	if [ $x -ge 4 ]
	then
		x=0
		echo -en "\033[2K\r"
		echo -en "Sleeping for zone to finish install"
	fi
	rm -rf /zones/$VMUUID/root/.zonecontrol/metadata.sock
	sleep 2
	echo -n "."
	((x++))
done
set -e

echo -en "\nZone install done.\n"
echo "Sideloading files."

curl -s -k https://raw.githubusercontent.com/project-fifo/breeder/0.9.2/conf-base.sh > /zones/$VMUUID/root/opt/local/bin/fifo-config
case $PackageName in
	aio)
		curl -s -k https://raw.githubusercontent.com/project-fifo/breeder/0.9.2/conf-snarl.sh >> /zones/$VMUUID/root/opt/local/bin/fifo-config
		curl -s -k https://raw.githubusercontent.com/project-fifo/breeder/0.9.2/conf-sniffle.sh >> /zones/$VMUUID/root/opt/local/bin/fifo-config
		curl -s -k https://raw.githubusercontent.com/project-fifo/breeder/0.9.2/conf-howl.sh >> /zones/$VMUUID/root/opt/local/bin/fifo-config
		;;
	snarl)
		curl -s -k https://raw.githubusercontent.com/project-fifo/breeder/0.9.2/conf-snarl.sh >> /zones/$VMUUID/root/opt/local/bin/fifo-config
		;;
	sniffle)
		curl -s -k https://raw.githubusercontent.com/project-fifo/breeder/0.9.2/conf-sniffle.sh >> /zones/$VMUUID/root/opt/local/bin/fifo-config
		;;
	howl)
		curl -s -k https://raw.githubusercontent.com/project-fifo/breeder/0.9.2/conf-howl.sh >> /zones/$VMUUID/root/opt/local/bin/fifo-config
		;;
esac
chmod +x /zones/$VMUUID/root/opt/local/bin/fifo-config

curl -k https://raw.githubusercontent.com/project-fifo/breeder/0.9.2/fifo_motd > /zones/$VMUUID/root/etc/fifo_motd.sh
chmod +x /zones/$VMUUID/root/etc/fifo_motd.sh
echo "" > /zones/$VMUUID/root/etc/motd

echo "/etc/fifo_motd.sh" >> /zones/$VMUUID/root/etc/profile

echo "Cleaning Image"
rm /zones/$VMUUID/root/opt/log
rm /zones/$VMUUID/root/root/fifo.gpg

echo "Creating Image"
imgadm create -i -c bzip2 $VMUUID name=fifo-$PackageName version=$PackageVersion -o /var/tmp

echo "Cleaning Up"
vmadm delete $VMUUID

echo "Done!"
