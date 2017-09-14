#!/bin/sh
echo "Not ready for use, please check back soon"
exit

# File to store the new version beffore applying the patch.
srclst="hostssources.lst"
#touch "$srclst"


if [[ $(grep -n "# Start of patch marker &5644 #" /etc/hosts | head -1 | cut -d \: -f 1) && grep -n "# End of patch marker &5844 #" /etc/hosts | tail -1 | cut -d \: -f
1 ]]; then
	patchExists=true
	startop=$(expr $(grep -n "# Start of patch marker &5644 #" /etc/hosts | head -1 | cut -d \: -f 1) - 1)
	endop=$(expr $(grep -n "# End of patch marker &5844 #" /etc/hosts | tail -1 | cut -d \: -f 1) - 1)
elif [[ $(grep -n "# Start of patch marker &5644 #" /etc/hosts | head -1 | cut -d \: -f 1) && grep -n "# End of patch marker &5844 #" /etc/hosts | tail -1 | cut -d \: -f
1 ]]; then

# Check if the hosts file has already been patched and if so cut out the exitsing patch to splice in the updated one
# if [[ $(grep -n "# Start of patch marker &5644 #" /etc/hosts | head -1 | cut -d \: -f 1) && grep -n "# End of patch marker &5844 #" /etc/hosts | tail -1 | cut -d \: -f 1 ]]; then

if patchExists; then
	echo "Updating hosts file that has been previously patched"
	finstring=""


	if [ -f /etc/hosts ] ; then
		head -$startop /etc/hosts >> "$srclst"
		tail -$(expr $endop - $(awk 'END { print NR }' /etc/hosts)) /etc/hosts >> "$srclst"
	fi



else
	upd=false
	echo Running First Install
	startop=$(awk 'END { print NR }' /etc/hosts)
	endop=$(awk 'END { print NR }' /etc/hosts)
fi



echo "# Start of patch marker &5644 #" >> "$srclst"
curl -L "http://adaway.org/hosts.txt" >> "$srclst"
curl -L "http://hosts-file.net/ad_servers.asp" >> "$srclst"
curl -L "http://winhelp2002.mvps.org/hosts.txt" >> "$srclst"
#For blocking youtube flash ads
echo "0.0.0.0       s.ytimg.com" >> "$srclst"
echo "# End of patch marker &5844 #" >> "$srclst"

sudo cp /etc/hosts /etc/hosts.old
sudo cp "$srclst" /etc/hosts

echo "The file at '/etc/hosts' has been patched successfully..."
rm "$srclst"
