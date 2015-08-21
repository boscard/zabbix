#!/bin/bash

# Requires jq from https://stedolan.github.io/jq/

wwwDir="/var/www/html/"
tmpFile="/tmp/wordpressActualVersion.tmp"
refTime=1440

function discovery() {
	echo '{'
	echo '  "data":['
	echo
	licznik=0
	for wordpress in `find $wwwDir -name wp-config.php`
	do
		if [ $licznik -ne 0 ]
		then
			echo ,
		fi
		licznik=$((licznik+1))
		wp_name=`echo $wordpress | sed -e 's:/wp-config.php::' -e 's:.*/::g'`
		echo -n "  { \"{#WPNAME}\":\"$wp_name\"}"
	done
	echo -e "\n"
	echo '  ]'
	echo '}'
}

function actualVersion() {
	updateVersion=0
	
	if [ -f "$tmpFile" ]
	then
		find $tmpFile -cmin +$refTime -delete
	fi

	if [ ! -f "$tmpFile" ]
	then
		updateVersion=1
	fi

	if [ $updateVersion -eq 1 ]
	then
		curl --silent https://api.wordpress.org/core/version-check/1.7/ | /var/lib/zabbix/jq .offers[0].version | sed 's/"//g' | cat > $tmpFile
	fi

	cat $tmpFile
}

function version() {
	egrep "^.wp_version" $wwwDir/$1/wp-includes/version.php | sed -e  s/"'"/""/g -e 's/.* //' -e 's/;//'
}

function isUpToDate() {
	actualVersion=`actualVersion`
	localVersion=`version $1`

	if [ "$actualVersion" == "$localVersion" ]
	then
		echo "Wordpress $1 is up to date";
	else
		echo "There is newer version of wordpress $1: $actualVersion > $localVersion"
	fi
}

case $1 in
	discovery)
		discovery;;
	version)
		version $2;;
	actualVersion)
		actualVersion;;
	isUpToDate)
		isUpToDate $2;;
esac
