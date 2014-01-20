#!/bin/bash

# to use this file, place this command in your ~/.bashrc:
#   source /path/to/this/file/control.sh

# edit these options below depending on your platform
XON_PROFILE="bitmissile"
XON_PASS="example"
XON_RPASS="example"

XON_IRCENABLED="0"

XON_GAMEDIR="$HOME/xonotic"
XON_HUBREPO="$HOME/hubservers"

XON_MAP_LIST_FILE="../packagelist.txt"
XON_MAP_DIR="$HOME/.xonotic/data"

alias xon-update-configs='cd $XON_HUBREPO && git stash && git pull && git stash pop'

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
	#  ${7}: _hooked_profile
	#  ${8}: _hooked_players
	#  ${9}: _hooked_port
	#  ${10}: _hooked_public
	#  ${11}: _hooked_type
	#  ${12}: _hooked_commands
	#  ${13}: _hooked_desc
	#  ${14}: _allow_extra_votes

	# check parameters
	if [ $# -ne 14 ]
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

	_hooked_profile="+set _hooked_profile \"${7}\""
	_hooked_players="+set _hooked_players \"${8}\""
	_hooked_port="+set _hooked_port \"${9}\""
	_hooked_public="+set _hooked_public \"${10}\""
	_hooked_type="+set _hooked_type \"${11}\""
	_hc="+set _hc_enabled \"${11}\""
	_hooked_commands="+alias _hooked_commands \"${12}\""
	_hooked_desc="+set _hooked_desc \"${13}\""
	_allow_extra_votes="+set _allow_extra_votes \"${14}\""

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
	echo "Starting Xonotic: \"xon-$2\" \"$2\" \"$3\" \"$4\" \"$5\" \"$_hooked_profile\" \"$_hooked_players\" \"$_hooked_port\" \"$_hooked_public\" \"$_hooked_type\" \"$_hooked_commands\" \"$_hooked_desc\" \"$_allow_extra_votes\""
	screen "$SCREENARGS" xon-"$2" \
	./all run dedicated \
	-sessionid "$2" \
	+set rcon_password \""$3"\" \
	+set rcon_restricted_password \""$4"\" \
	"$_hooked_profile" "$_hooked_players" "$_hooked_port" "$_hooked_public" "$_hooked_type" "$_hc_enabled" "$_hooked_commands" "$_hooked_desc" "$_allow_extra_votes" \
	+serverconfig \""$5"\"

	# TODO:
	# check whether the session is already running before starting: $(ps aux | grep -v "grep" | grep "ctfd")
}

function _xon-start-wrapper() {
	# arguments
	#  ${1}: attached
	#  ${2}: sessionid
	#  ${3}: hooked_players
	#  ${4}: hooked_port
	#  ${5}: hooked_public
	#  ${6}: hooked_type
	#  ${7}: hooked_commands
	#  ${8}: hooked_desc
	#  ${9}: allow_extra_votes

	if [ $# -eq 9 ]
	then
		_xon-start-explicit "$1" "$2" "$XON_PASS" "$XON_RPASS" "sv-hookable.cfg" "$XON_IRCENABLED" "$XON_PROFILE" "$3" "$4" "$5" "$6" "$7" "$8" "$9"
	else
		echo "_xon-start-wrapper: Incorrect argument count!"
	fi
}

# DO NOT CALL THESE DIRECTLY, CALL IT THROUGH THE "xon-start" COMMAND!
# If a server is added to these lists, its port is effectively used up and cannot be used with any different sessionid

# options (ignore the first one, it is passed to the function):
#   attached sessionid maxplayers port sv_public server_type commands description extra_votes

# Persistently returning servers start at port 27100
function xon-duel()    { _xon-start-wrapper "$1" "duel"    "16" "27100" "1" "pickup"  "duel"             "Duel" "0"; }
function xon-ctf-mh()  { _xon-start-wrapper "$1" "ctf-mh"  "20" "27101" "1" "public"  "ctf; minstahook"  "CTF Instagib+Hook" "0"; }
function xon-ctf-wa()  { _xon-start-wrapper "$1" "ctf-wa"  "20" "27102" "1" "public"  "ctf; weaponarena" "CTF Weaponarena" "0"; }
function xon-ka-mh()   { _xon-start-wrapper "$1" "ka-mh"   "20" "27103" "1" "public"  "ka; minstahook"   "Keepaway Instagib+Hook" "0"; }
function xon-ka-wa()   { _xon-start-wrapper "$1" "ka-wa"   "20" "27104" "1" "public"  "ka; weaponarena"  "Keepaway Weaponarena" "0"; }
function xon-tourney() { _xon-start-wrapper "$1" "tourney" "32" "27105" "0" "tourney" "duel"             "Tourney" "1"; }
function xon-votable() { _xon-start-wrapper "$1" "votable" "20" "27106" "1" "public"  "dm"               "Votable" "1"; }
function xon-private() { _xon-start-wrapper "$1" "private" "32" "27107" "0" "pickup"  "4v4tdm"           "Private" "1"; }
function xon-lms()     { _xon-start-wrapper "$1" "lms"     "20" "27108" "1" "public"  "lms"              "Last Man Standing" "0"; }
function xon-ffa()     { _xon-start-wrapper "$1" "ffa"     "20" "27109" "1" "public"  "dm"               "Free For All" "0"

# Special/weekend event servers start at 27500
function xon-meleelms() { _xon-start-wrapper "$1" "lms"      "48" "27500" "1" "public" "lms; meleeonly"          "LMS Melee-Only" "0"; }
function xon-ctf-mhn()  { _xon-start-wrapper "$1" "ctf-mhn"  "20" "27501" "1" "public" "ctf; minstahook; nades"  "CTF Instagib Special" "0"; }


function _xon-all-bitmissile() {
	xon-duel "0"
	xon-ctf-wa "0"
	#xon-private "0"
	xon-votable "0"
}

function _xon-all-wtwrp() {
	xon-duel "0"
	xon-ctf-wa "0"
	xon-lms "0"
	xon-private "0"
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
