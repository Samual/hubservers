#!/bin/bash

echo "update-maps.sh: Beginning package update in \'$XON_MAP_DIR\'"

echo "update-maps.sh: Deleting packages we no longer want..."
for local in $XON_MAP_DIR/*; do
	MAP=$(basename $local)
	MAP_PRESENT=0
	for remote in $(cat $XON_MAP_LIST_FILE); do
		MAPL=$(basename $remote)
		if [ "$MAP" == "$MAPL" ]; then
			MAP_PRESENT=1
		fi
	done
	if [ $local != "$XON_MAP_DIR/*" ] && [[ $local == *.pk3 ]] && [ $MAP_PRESENT -eq 0 ]; then
		rm -v $local
	fi
done

echo "update-maps.sh: Downloading new packages..."
for remote in $(cat $XON_MAP_LIST_FILE); do
	MAP=$(basename $remote)
	if [ ! -f $MAP ]; then
		echo "Downloading $remote"
		wget -qO "$XON_MAP_DIR/$MAP" "$remote"
	fi
done

echo "update-maps.sh: Update complete!"
