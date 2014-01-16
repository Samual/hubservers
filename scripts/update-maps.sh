#!/bin/bash
for local in $XON_MAP_DIR/*; do
	MAP=$(basename $local)
	MAP_PRESENT=0
	for remote in $(cat $XON_MAP_LIST_FILE); do
		MAPL=$(basename $remote)
		if [ "$MAP" == "$MAPL" ]; then
			MAP_PRESENT=1
		fi
	done
	if [ $local != "$XON_MAP_DIR/*" ] && [ $MAP_PRESENT -eq 0 ]; then
		rm $local
	fi
done

for remote in $(cat $XON_MAP_LIST_FILE); do
	MAP=$(basename $remote)
	if [ ! -f $MAP ]; then
		wget -qO "$XON_MAP_DIR/$MAP" "$remote"
	fi
done
