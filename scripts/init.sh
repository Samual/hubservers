#!/bin/bash
# PLACE ~/path/to/this/file/./init.sh IN YOUR ~/.bashrc
XON_PROFILE="bitmissile"
XON_PASS="example"

XON_IRCENABLED="n"

XON_GAMEDIR="$HOME/xonotic"
XON_HUBREPO="$HOME/hubservers"

XON_MAP_LIST_FILE="../packagelist.txt"
XON_MAP_DIR="$HOME/.xonotic/data"

alias xon-update-configs='cd $XON_HUBREPO && git stash && git pull && git stash pop'
#alias xon-update-maps='cd $XON_HUBREPO/scripts && ./update-maps.sh'

alias xon-stop='killall -v -i -s SIGTERM darkplaces-dedicated'
alias xon-kill='killall -v -i -s SIGKILL darkplaces-dedicated'

function _xon-start-explicit() {
	# required arguments:
	#  $1: attached
	#  $2: sessionid
	#  $3: profile
	#  $4: password
	#  $5: config
	# optional arguments:
	#  $6: irc
	#  $7: dedimode
	#  $8: dedimutator
	#  $9: deditype
	#  $10: dedidescription

	# check parameters
	if [[ -z "$2" || -z "$3" || -z "$4" || -z "$5" ]]
	then
		echo "Incorrect parameters for xon-start-explicit!"
		echo "Input: \"$@\""
		return
	fi

	# is this session going to be attached?
	if [ "$1" == "y" ]
	then
		SCREENARGS="-mS"
	else
		SCREENARGS="-dmS"
	fi
	
	# fill optional values (if applicable)
	if [[ -n "$7" && -n "$8" && -n "$9" && -n "${10}" ]]
	then
		DEDIMODE="+set _dedimode \"$7\""
		DEDIMUTATOR="+set _dedimutator \"$8\""
		DEDITYPE="+set _deditype \"$9\""
		DEDIDESC="+set _dedidescription \"${10}\""
	fi

	# switch to game directory
	echo "cd $XON_GAMEDIR"
	cd "$XON_GAMEDIR"

	# now execute the server start command
	# note that it is a single command, escaped into multiple lines!
	echo "Starting Xonotic: \"xon-$2\" \"$2\" \"$3\" \"$4\" \"$5\" \"$DEDIMODE\" \"$DEDIMUTATOR\" \"$DEDITYPE\" \"$DEDIDESC\""
	screen "$SCREENARGS" \"xon-$2\" \
	./all run dedicated \
	-sessionid "$2" \
	+set _profile \""$3"\" \
	+set rcon_password \""$4"\" \
	+serverconfig \""$5"\" \
	"$DEDIMODE" "$DEDIMUTATOR" "$DEDITYPE" "$DEDIDESC"

	# switch to rcon2irc directory
	echo "cd $XON_HUBREPO/rcon2irc"
	cd "$XON_HUBREPO/rcon2irc"

	# finally lets execute the rcon2irc command
	if [ "$6" == "y" ]
	then
		echo "Starting rcon2irc: 'xon-irc-\"$3\"-\"$2\"', 'hub-\"$3\"-\"$2\".conf'"
		screen -dmS \"xon-irc-$3-$2\" perl rcon2irc.pl \"hub-$3-$2.conf\"
	else
		echo "Skipping rcon2irc..."
	fi

	# TODO:
	# check whether the session is already running before starting: $(ps aux | grep -v "grep" | grep "ctfd")
}

function _xon-start-wrapper() {
	# required arguments:
	#  $1: attached
	#  $2: sessionid
	#  $3: config
	# optional arguments:
	#  $4: dedimode
	#  $5: dedimutator
	#  $6: deditype
	#  $7: dedidescription
	
	if [ $# -eq 7 ]
	then
		_xon-start-explicit "$1" "$2" "$XON_PROFILE" "$XON_PASS" "$3" "$XON_IRCENABLED" "$4" "$5" "$6" "$7"
	elif [ $# -eq 3 ]
	then
		_xon-start-explicit "$1" "$2" "$XON_PROFILE" "$XON_PASS" "$3" "$XON_IRCENABLED"
	else
		echo "_xon-start-wrapper: Incorrect argument count!"
	fi
}

# DO NOT CALL THESE DIRECTLY, CALL IT THROUGH THE "xon-start" COMMAND!
function xon-duel()    { _xon-start-wrapper "$1" "duel"    "sv-dedicated.cfg" "duel" "echo"        "pickup" "Duel"; }
function xon-ctf-mh()  { _xon-start-wrapper "$1" "ctf-mh"  "sv-dedicated.cfg" "ctf"  "minstahook"  "public" "CTF Instagib+Hook"; }
function xon-ctf-wa()  { _xon-start-wrapper "$1" "ctf-wa"  "sv-dedicated.cfg" "ctf"  "weaponarena" "public" "CTF Weaponarena"; }
function xon-ka-mh()   { _xon-start-wrapper "$1" "ka-mh"   "sv-dedicated.cfg" "ka"   "minstahook"  "public" "Keepaway Instagib+Hook"; }
function xon-ka-wa()   { _xon-start-wrapper "$1" "ka-wa"   "sv_dedicated.cfg" "ka"   "weaponarena" "public" "Keepaway Weaponarena"; }
function xon-priv-1()  { _xon-start-wrapper "$1" "priv-1"  "sv-private-1.cfg"; }
function xon-priv-2()  { _xon-start-wrapper "$1" "priv-2"  "sv-private-2.cfg"; }
function xon-tourney() { _xon-start-wrapper "$1" "tourney" "sv-tourney.cfg"; }
function xon-votable() { _xon-start-wrapper "$1" "votable" "sv-votable.cfg"; }

function _xon-all-bitmissile() {
	xon-duel "n"
	xon-ctf-wa "n"
	xon-votable "n"
}

function _xon-all-wtwrp() {
	xon-duel "n"
	xon-ctf-wa "n"
	xon-ka-mh "n"
	xon-votable "n"
}

function _xon-all-smb() {
	xon-votable "n"
}

function xon-start() {
	# required: $1: function
	# optional: $2: attached
	if [ $# -eq 0 ]
	then
		echo "xon-start: Incorrect parameters!"
	elif [ "$1" == "all" ]
	then
		if [ -n "$XON_PROFILE" ]
		then
			echo "Launching all servers for '$XON_PROFILE'"
			_xon-all-$XON_PROFILE
		else
			echo "XON_PROFILE field was empty?"
		fi
	else
		if [ "$2" == "y" ]
		then
			ATTACHED="y"
		else
			ATTACHED="n"
		fi
		$1 "$ATTACHED"
	fi
}

function xon-update-maps() {
	echo "xon-update-maps: Beginning package update in '$XON_MAP_DIR'"
	
	echo "xon-update-maps: Checking for packages we no longer want..."
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

	echo "xon-update-maps: Downloading new packages..."
	for remote in $(cat $XON_MAP_LIST_FILE)
	do
		MAP=$(basename $remote)
		if [ ! -f $XON_MAP_DIR/$MAP ]
		then
			#echo "Downloading $remote"
			wget --output-document="$XON_MAP_DIR/$MAP" "$remote"
		else
			echo "Already have '$MAP', skipping"
		fi
	done

	echo "xon-update-maps: Update complete!"
}
