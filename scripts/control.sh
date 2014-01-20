#!/bin/bash
# PLACE ~/path/to/this/file/./init.sh IN YOUR ~/.bashrc
XON_PROFILE="bitmissile"
XON_PASS="example"
XON_RPASS="example"

XON_IRCENABLED="n"

XON_GAMEDIR="$HOME/xonotic"
XON_HUBREPO="$HOME/hubservers"

XON_MAP_LIST_FILE="../packagelist.txt"
XON_MAP_DIR="$HOME/.xonotic/data"

alias xon-update-configs='cd $XON_HUBREPO && git stash && git pull && git stash pop'
#alias xon-update-maps='cd $XON_HUBREPO/scripts && ./update-maps.sh'

function stopxonotic() {
	ps -a -o pid,user,args | grep -v "grep" | grep -v "catchsegv" | grep "sessionid"
	killall -i -s SIGTERM "darkplaces-dedicated"
}

function killxonotic() {
	ps -a -o pid,user,args | grep -v "grep" | grep -v "catchsegv" | grep "sessionid"
	killall -i -s SIGKILL "darkplaces-dedicated"
}

function _xon-start-explicit() {
	# arguments
	#  ${1}: attached
	#  ${2}: sessionid
	#  ${3}: password
	#  ${4}: restricted password
	#  ${5}: config
	#  ${6}: irc
	#  ${7}: hooked_profile
	#  ${8}: hooked_port
	#  ${9}: hooked_public
	#  ${10}: hooked_type
	#  ${11}: hooked_commands
	#  ${12}: hooked_desc
	#  ${13}: allow_extra_votes

	# check parameters
	if [ $# -ne 13 ]
	then
		echo "Incorrect parameters for xon-start-explicit!"
		echo "Input: \"$@\""
		return
	fi

	# is this session going to be attached?
	if [ "$1" -eq 1 ]
	then
		SCREENARGS="-mS"
	else
		SCREENARGS="-dmS"
	fi

	hooked_profile="+set _hooked_profile \"${7}\""
	hooked_port="+set _hooked_port \"${8}\""
	hooked_public="+set _hooked_public \"${9}\""
	hooked_type="+set _hooked_type \"${10}\""
	hooked_commands="+set _hooked_commands \"${11}\""
	hooked_desc="+set _hooked_desc \"${12}\""
	allow_extra_votes="+set _allow_extra_votes \"${13}\""

	# now that we're done handling arguments/variables, execute
	# rcon2irc first in case we need to attach the server screen.
	echo "cd $XON_HUBREPO/rcon2irc"
	cd "$XON_HUBREPO/rcon2irc"
	if [ "$6" -eq 1 ]
	then
		echo "Starting rcon2irc: 'xon-irc-\"$7\"-\"$2\"', 'hub-\"$7\"-\"$2\".conf'"
		screen -dmS xon-irc-"$7"-"$2" perl rcon2irc.pl \"hub-"$7"-"$2".conf\"
	else
		echo "Skipping rcon2irc..."
	fi

	# now execute the server start command
	# note that it is a single command, escaped into multiple lines!
	echo "cd $XON_GAMEDIR"
	cd "$XON_GAMEDIR"
	echo "Starting Xonotic: \"xon-$2\" \"$2\" \"$3\" \"$4\" \"$5\" \"$hooked_profile\" \"$hooked_port\" \"$hooked_public\" \"$hooked_type\" \"$hooked_commands\" \"$hooked_desc\" \"$allow_extra_votes\""
	screen "$SCREENARGS" xon-"$2" \
	./all run dedicated \
	-sessionid "$2" \
	+set rcon_password \""$3"\" \
	+set rcon_restricted_password \""$4"\" \
	"$hooked_profile" "$hooked_port" "$hooked_public" "$hooked_type" "$hooked_commands" "$hooked_desc" "$allow_extra_votes" \
	+serverconfig \""$5"\"

	# TODO:
	# check whether the session is already running before starting: $(ps aux | grep -v "grep" | grep "ctfd")
}

function _xon-start-wrapper() {
	# arguments
	#  ${1}: attached
	#  ${2}: sessionid
	#  ${3}: config
	#  ${4}: hooked_port
	#  ${5}: hooked_public
	#  ${6}: hooked_type
	#  ${7}: hooked_commands
	#  ${8}: hooked_desc
	#  ${9}: allow_extra_votes

	if [ $# -eq 9 ]
	then
		_xon-start-explicit "$1" "$2" "$XON_PASS" "$XON_RPASS" "$3" "$XON_IRCENABLED" "$XON_PROFILE" "$4" "$5" "$6" "$7" "$8" "$9"
	else
		echo "_xon-start-wrapper: Incorrect argument count!"
	fi
}

# DO NOT CALL THESE DIRECTLY, CALL IT THROUGH THE "xon-start" COMMAND!
function xon-duel()    { _xon-start-wrapper "$1" "duel"    "sv-hookable.cfg" "27000" "1" "pickup" "duel"             "Duel" "1"; }
function xon-ctf-mh()  { _xon-start-wrapper "$1" "ctf-mh"  "sv-hookable.cfg" "27000" "1" "public" "ctf; minstahook"  "CTF Instagib+Hook" "0"; }
function xon-ctf-wa()  { _xon-start-wrapper "$1" "ctf-wa"  "sv-hookable.cfg" "27000" "1" "public" "ctf; weaponarena" "CTF Weaponarena" "0"; }
function xon-ka-mh()   { _xon-start-wrapper "$1" "ka-mh"   "sv-hookable.cfg" "27000" "1" "public" "ka; minstahook"   "Keepaway Instagib+Hook" "0"; }
function xon-ka-wa()   { _xon-start-wrapper "$1" "ka-wa"   "sv-hookable.cfg" "27000" "1" "public" "ka; weaponarena"  "Keepaway Weaponarena" "0"; }
function xon-tourney() { _xon-start-wrapper "$1" "tourney" "sv-hookable.cfg" "27000" "0" "pickup" "duel"             "Tourney" "1"; }
function xon-votable() { _xon-start-wrapper "$1" "votable" "sv-hookable.cfg" "27000" "1" "public" "dm"               "Votable" "1"; }

#function xon-duel()    { _xon-start-wrapper "$1" "duel"    "sv-dedicated.cfg" "duel" "echo"        "pickup" "Duel"; }
#function xon-ctf-mh()  { _xon-start-wrapper "$1" "ctf-mh"  "sv-dedicated.cfg" "ctf"  "minstahook"  "public" "CTF Instagib+Hook"; }
#function xon-ctf-wa()  { _xon-start-wrapper "$1" "ctf-wa"  "sv-dedicated.cfg" "ctf"  "weaponarena" "public" "CTF Weaponarena"; }
#function xon-ka-mh()   { _xon-start-wrapper "$1" "ka-mh"   "sv-dedicated.cfg" "ka"   "minstahook"  "public" "Keepaway Instagib+Hook"; }
#function xon-ka-wa()   { _xon-start-wrapper "$1" "ka-wa"   "sv_dedicated.cfg" "ka"   "weaponarena" "public" "Keepaway Weaponarena"; }
#function xon-priv-1()  { _xon-start-wrapper "$1" "priv-1"  "sv-private-1.cfg"; }
#function xon-priv-2()  { _xon-start-wrapper "$1" "priv-2"  "sv-private-2.cfg"; }
#function xon-tourney() { _xon-start-wrapper "$1" "tourney" "sv-tourney.cfg"; }
#function xon-votable() { _xon-start-wrapper "$1" "votable" "sv-votable.cfg"; }

function _xon-all-bitmissile() {
	xon-duel "0"
	xon-ctf-wa "0"
	xon-votable "0"
}

function _xon-all-wtwrp() {
	xon-duel "0"
	xon-ctf-wa "0"
	xon-ka-mh "0"
	xon-votable "0"
}

function _xon-all-smb() {
	xon-votable "0"
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
			_xon-all-"$XON_PROFILE"
		else
			echo "XON_PROFILE field was empty?"
		fi
	else
		if [ "$2" -eq 1 ]
		then
			ATTACHED="1"
		else
			ATTACHED="0"
		fi
		"$1" "$ATTACHED"
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
