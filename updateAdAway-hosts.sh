#!/bin/sh
echo "Not ready for use, please check back soon"
exit

hostslocation="/etc/hosts"
# File to store the new version beffore applying the patch.
srclst="hostssources.lst"
#touch "$srclst"
userown="userown.lst"
#touch "$userown"

if [[ $(grep -n "# Start of patch marker &5644 #" $hostslocation | head -1 | cut -d \: -f 1) && grep -n "# End of patch marker &5844 #" $hostslocation | tail -1 | cut -d \: -f
1 ]]; then
	patchExists=true
	startop=$(expr $(grep -n "# Start of patch marker &5644 #" $hostslocation | head -1 | cut -d \: -f 1) - 1)
	endop=$(expr $(grep -n "# End of patch marker &5844 #" $hostslocation | tail -1 | cut -d \: -f 1) - 1)
elif grep -Fxq $hostslocation


#elif [[ $(grep -n "# Start of patch marker &5644 #" $hostslocation | head -1 | cut -d \: -f 1) && grep -n "# End of patch marker &5844 #" $hostslocation | tail -1 | cut -d \: -f 1 ]]; then

# Check if the hosts file has already been patched and if so cut out the exitsing patch to splice in the updated one
# if [[ $(grep -n "# Start of patch marker &5644 #" $hostslocation | head -1 | cut -d \: -f 1) && grep -n "# End of patch marker &5844 #" $hostslocation | tail -1 | cut -d \: -f 1 ]]; then

if patchExists; then
	echo "Updating hosts file that has been previously patched"
	finstring=""


	if [ -f $hostslocation ] ; then
		head -$startop $hostslocation >> "$srclst"
		tail -$(expr $endop - $(awk 'END { print NR }' $hostslocation)) $hostslocation >> "$srclst"
	fi



else
	upd=false
	echo Running First Install
	startop=$(awk 'END { print NR }' $hostslocation)
	endop=$(awk 'END { print NR }' $hostslocation)
fi


# Download lists and insert markers for splicing on next update
echo "# Start of patch marker &5644 #" >> "$srclst"
# Insert Warning Message to users editing hosts on their own
echo "!!!Make no changes below here!!!, they will be deleted if they are inbetween the Start and End markers when you update your ad list"
echo
curl -L "http://adaway.org/hosts.txt" >> "$srclst"
curl -L "http://hosts-file.net/ad_servers.asp" >> "$srclst"
curl -L "http://winhelp2002.mvps.org/hosts.txt" >> "$srclst"
#For blocking youtube flash ads
echo "0.0.0.0       s.ytimg.com" >> "$srclst"
echo "# End of patch marker &5844 #" >> "$srclst"

sudo cp $hostslocation $hostslocation.old
sudo cp "$srclst" $hostslocation

echo "The file at '$hostslocation' has been patched successfully..."
rm "$srclst"
