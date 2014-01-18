#!/bin/bash
# PLACE ~/path/to/this/file/./init.sh IN YOUR ~/.bashrc
XON_PROFILE="bitmissile"
XON_PASS="example"

XON_GAMEDIR="$HOME/xonotic"
XON_HUBREPO="$HOME/hubservers"

XON_MAP_LIST_FILE="../packagelist.txt"
XON_MAP_DIR="$HOME/.xonotic/data"

function xon-start-explicit() {
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

	if [ "$1" == "y" ]
	then
		SCREENARGS="-mS"
	else
		SCREENARGS="-dmS"
	fi

	# check parameters
	if [[ -z "$2" || -z "$3" || -z "$4" || -z "$5" ]]
	then
		echo "Incorrect parameters for xon-start-explicit!"
		echo "Input: \"$@\""
		return
	fi
	
	# fill optional values (if applicable)
	if [[ -z "$7" || -z "$8" || -z "$9" || -z "${10}" ]]
	then
		DEDIMODE=""
		DEDIMUTATOR=""
		DEDITYPE=""
		DEDIDESC=""
	else
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
	echo "Starting Xonotic!"
	screen "$SCREENARGS" \"xon-"$2"\" \
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
		echo "Starting rcon2irc!"
		screen -dmS \"xon-irc-"$3"-"$2"\" perl rcon2irc.pl \"hub-"$3"-"$2".conf\"
	else
		echo "Skipping rcon2irc..."
	fi

	# TODO:
	# check whether the session is already running before starting: $(ps aux | grep -v "grep" | grep "ctfd")
}

#XON_COMMON="./all run dedicated +set _profile \"$XON_PROFILE\" +set rcon_password \"$XON_PASS\" +serverconfig"


alias xon-update-configs='cd $XON_HUBREPO && git stash && git pull && git stash pop'
alias xon-update-maps='cd $XON_HUBREPO/scripts && ./update-maps.sh'

alias xon-stop-servers='killall -i -s SIGTERM darkplaces-dedicated'
alias xon-kill-servers='killall -i -s SIGKILL darkplaces-dedicated'

#alias xon-start-servers='xon-ctf-mh && xon-ctf-wa && xon-ka-mh && xon-ka-wa && xon-priv-1 && xon-priv-2 && xon-tourney &&xon-votable'
#alias xon-start-bitmissile='xon-ctf-mh && xon-ctf-wa && xon-priv-1'

#alias xon-duel='cd $XON_GAMEDIR && screen -dmS xon-duel $XON_COMMON sv-dedicated.cfg -sessionid duel +set \_dedimode \"duel\" +set \_dedimutator \"\" +set \_deditype \"pickup\" +set \_dedidescription \"Duel\"'
#alias xon-ctf-mh='cd $XON_GAMEDIR && screen -dmS xon-ctf-mh $XON_COMMON sv-dedicated.cfg -sessionid ctf-mh +set \_dedimode \"ctf\" +set \_dedimutator \"minstahook\" +set \_deditype \"public\" +set \_dedidescription \"CTF Instagib+Hook\"'
#alias xon-ctf-wa='cd $XON_GAMEDIR && screen -dmS xon-ctf-wa $XON_COMMON sv-dedicated.cfg -sessionid ctf-wa +set \_dedimode \"ctf\" +set \_dedimutator \"weaponarena\" +set \_deditype \"public\" +set \_dedidescription \"CTF Weaponarena\"'
#alias xon-ka-mh='cd $XON_GAMEDIR && screen -dmS xon-ka-mh $XON_COMMON sv-dedicated.cfg -sessionid ka-mh +set \_dedimode \"keepaway\" +set \_dedimutator \"minstahook\" +set \_deditype \"public\" +set \_dedidescription \"Keepaway Instagib+Hook\"'
#alias xon-ka-wa='cd $XON_GAMEDIR && screen -dmS xon-ka-wa $XON_COMMON sv-dedicated.cfg -sessionid ka-wa +set \_dedimode \"keepaway\" +set \_dedimutator \"weaponarena\" +set \_deditype \"public\" +set \_dedidescription \"Keepaway Weaponarena\"'
#alias xon-priv-1='cd $XON_GAMEDIR && screen -dmS xon-priv-1 $XON_COMMON sv-private-1.cfg -sessionid priv-1'
#alias xon-priv-2='cd $XON_GAMEDIR && screen -dmS xon-priv-2 $XON_COMMON sv-private-2.cfg -sessionid priv-1'
#alias xon-tourney='cd $XON_GAMEDIR && screen -dmS xon-tourney $XON_COMMON sv-tourney.cfg -sessionid tourney'
#alias xon-votable='cd $XON_GAMEDIR && screen -dmS xon-votable $XON_COMMON sv-votable.cfg -sessionid votable'
#alias xon-spawnweapons='cd $XON_GAMEDIR && screen -dmS xon-spawnweapons $XON_COMMON sv-spawnweapons.cfg -sessionid spawnweapons'

#alias xon-irc-eu-ctf-wa='cd $XON_HUBREPO/rcon2irc/ && screen -dmS xon-irc-eu-ctf-wa perl rcon2irc.pl hub-eu-ctf-wa.conf'
#alias xon-irc-eu-ka-mh='cd $XON_HUBREPO/rcon2irc/ && screen -dmS xon-irc-eu-ka-mh perl rcon2irc.pl hub-eu-ka-mh.conf'
#alias xon-irc-eu-votable='cd $XON_HUBREPO/rcon2irc/ && screen -dmS xon-irc-eu-votable perl rcon2irc.pl hub-eu-votable.conf'
#alias xon-irc-na-ctf-wa='cd $XON_HUBREPO/rcon2irc/ && screen -dmS xon-irc-na-ctf-wa perl rcon2irc.pl hub-na-ctf-wa.conf'
#alias xon-irc-na-ka-mh='cd $XON_HUBREPO/rcon2irc/ && screen -dmS xon-irc-na-ka-mh perl rcon2irc.pl hub-na-ka-mh.conf'
#alias xon-irc-na-votable='cd $XON_HUBREPO/rcon2irc/ && screen -dmS xon-irc-na-votable perl rcon2irc.pl hub-na-votable.conf'
