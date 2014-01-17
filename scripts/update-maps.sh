#!/bin/bash

source init.sh

echo "update-maps.sh: Beginning package update in '$XON_MAP_DIR'"

echo "update-maps.sh: Checking for packages we no longer want..."
for local in $XON_MAP_DIR/*
do
	MAP=$(basename $local)
	MAP_PRESENT=0
	for remote in $(cat $XON_MAP_LIST_FILE)
	do
		MAPL=$(basename $remote)
		if [ "$MAP" == "$MAPL" ]
		then
			MAP_PRESENT=1
		fi
	done
	if [ $local != "$XON_MAP_DIR/*" ] && [[ $local == *.pk3 ]] && [ $MAP_PRESENT == 0 ]
	then
		#echo "Deleting $local"
		rm -v $local
	fi
done

echo "update-maps.sh: Downloading new packages..."
for remote in $(cat $XON_MAP_LIST_FILE)
do
	MAP=$(basename $remote)
	if [ ! -f $XON_MAP_DIR/$MAP ]
	then
		echo "Downloading $remote"
		wget --no-verbose --output-document="$XON_MAP_DIR/$MAP" "$remote"
	else
		echo "Already have $map, skipping"
	fi
done

echo "update-maps.sh: Update complete!"
