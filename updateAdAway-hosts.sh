#!/bin/sh
echo "This project is not ready for use, please check back soon"
exit

# Make sure /etc/hosts exists and if not ask user where hosts file is
if [[ $(cat /etc/hosts) ]]; then
	hostslocation="/etc/hosts"
else
	echo "Where is your hosts file? I couldn't find it at /etc/hosts ;_;"
	read -p ">" hostslocation
fi
# File to store the new version beffore applying the patch.
srclst="hostssources.lst"
#touch "$srclst"
userown="userown.lst"
#touch "$userown"

# Check if start and end exist and setting a variable for them
if [[ $(grep -n "# Start of patch marker &5644 #" $hostslocation) ]]; then
	startexists=true
else
	startexists=false
fi

if [[ $(grep -n "# End of patch marker &5844 #" $hostslocation) ]]; then
	endexists=true
else
	endexists=false
fi


# Check if both start AND end headers exist
if $startexists && $endexists ; then
	patchExists=true
	startop=$(grep -n "# Start of patch marker &5644 #" $hostslocation | head -1 | cut -d \: -f 1)
	endop=$(grep -n "# End of patch marker &5844 #" $hostslocation | tail -1 | cut -d \: -f 1)
elif $startexists ^ $endexists ; then
	echo Incomplete or failed patch detected
	return 1
	exit
else
	patchExists=false
fi


#elif [[ $(grep -n "# Start of patch marker &5644 #" $hostslocation | head -1 | cut -d \: -f 1) && grep -n "# End of patch marker &5844 #" $hostslocation | tail -1 | cut -d \: -f 1 ]]; then

# Check if the hosts file has already been patched and if so cut out the exitsing patch to splice in the updated one
# if [[ $(grep -n "# Start of patch marker &5644 #" $hostslocation | head -1 | cut -d \: -f 1) && grep -n "# End of patch marker &5844 #" $hostslocation | tail -1 | cut -d \: -f 1 ]]; then

if [ -f $hostslocation ] ; then
	if patchExists; then
		# Inform the user what the program thinks it is doing
		echo "Updating hosts file that has been previously patched. There back captain, the ads!"
		# Set the string that will tell the user what has happened at the end of execution
		finstring="Updates finished. There gone, for now."

		# Saftey procaution to make sure you dont "head" below 1
		if (( $startop > 1 )) ; then
			# Cut the top off to save it after the patch
			head -$(expr $startop - 1) $hostslocation >> "$srclst"
			tail -$(expr $endop - $(awk 'END { print NR }' $hostslocation)) $hostslocation >> "$srclst"
		else
			echo "You have nothing in $hostslocation"
		fi

	elif !patchExists; then
		# Inform the user what the program thinks it is doing
		echo "Running first time patch. Welcome to an ad free world! We protect our own."
		# Set the string that will tell the user what has happened at the end of execution
		finstring="Installed. Your safe now, no one can hurt you here."

		cat $hostslocation > $srclst &&
		runPatch=true

	fi
fi

if runPatch ; then
	# Download lists and insert markers for splicing on next update
	echo "# Start of patch marker &5644 #" >> "$srclst"
	# Insert Warning Message to users editing hosts on their own
	echo "!!!Make no changes below here!!!, they will be deleted if they are inbetween the Start and End markers when you update your ad list"
	echo
	# Download the lists merge them to our list
	curl -L "http://adaway.org/hosts.txt" >> "$srclst"
	curl -L "http://hosts-file.net/ad_servers.asp" >> "$srclst"
	curl -L "http://winhelp2002.mvps.org/hosts.txt" >> "$srclst"
	#For blocking youtube flash ads
	echo "0.0.0.0       s.ytimg.com" >> "$srclst"
	echo "# End of patch marker &5844 #" >> "$srclst"

	sudo cp $hostslocation $hostslocation.old &&
	sudo cp "$srclst" $hostslocation

	echo "The file at '$hostslocation' has been patched successfully..."
	rm "$srclst"
fi
