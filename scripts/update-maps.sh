#!/bin/bash

MAP_LIST_FILE='packagelist-CONTINENT.txt'
MAP_DIR='~/maps/'

for local in "$MAP_DIR/*"; do
	MAP=$(basename $local)
	MAP_PRESENT=0
	for remote in $(cat $MAP_LIST_FILE); do
		MAPL=$(basename $remote)
		if [ "$MAP" == "$MAPL" ]; then
			MAP_PRESENT=1
		fi
	done
	if [ $MAP_PRESENT -eq 0 ]; then
		rm $local
	fi
done

for remote in $(cat $MAP_LIST_FILE); do
	MAP=$(basename $remote)
	if [ !-f $MAP ]; then
		wget -qO "$MAP_DIR/$MAP" "$remote"
	fi
done