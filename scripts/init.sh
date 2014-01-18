# PLACE ~/path/to/this/file/./init.sh IN YOUR ~/.bashrc
XON_PROFILE="bitmissile"
XON_PASS="example"

XON_GAMEDIR="$HOME/xonotic/"
XON_HUBREPO="$HOME/hubservers/"

XON_MAP_LIST_FILE="../packagelist-eu.txt"
XON_MAP_DIR="$HOME/.xonotic/data"

XON_COMMON="./all run dedicated +set _profile \"$XON_PROFILE\" +set rcon_password \"$XON_PASS\" +serverconfig"


alias xon-update-configs='cd $XON_HUBREPO && git stash && git pull && git stash pop'
alias xon-update-maps='cd $XON_HUBREPO/scripts && ./update-maps.sh'

alias xon-stop-servers='killall darkplaces-dedicated -s SIGKILL'

alias xon-start-servers='xon-ctf-mh && xon-ctf-wa && xon-ka-mh && xon-ka-wa && xon-priv-1 && xon-priv-2 && xon-tourney &&xon-votable'
alias xon-start-bitmissile='xon-ctf-mh && xon-ctf-wa && xon-priv-1'

alias xon-ctf-mh='cd $XON_GAMEDIR && screen -dmS xon-ctf-mh $XON_COMMON sv-dedicated.cfg -sessionid ctf-mh +set \_dedimode \"ctf\" +set \_dedimutator \"minstahook\" +set \_dedidescription \"CTF Instagib+Hook\"'
alias xon-ctf-wa='cd $XON_GAMEDIR && screen -dmS xon-ctf-wa $XON_COMMON sv-dedicated.cfg -sessionid ctf-wa +set \_dedimode \"ctf\" +set \_dedimutator \"weaponarena\" +set \_dedidescription \"CTF Weaponarena\"'
alias xon-ka-mh='cd $XON_GAMEDIR && screen -dmS xon-ka-mh $XON_COMMON sv-dedicated.cfg -sessionid ka-mh +set \_dedimode \"keepaway\" +set \_dedimutator \"minstahook\" +set \_dedidescription \"Keepaway Instagib+Hook\"'
alias xon-ka-wa='cd $XON_GAMEDIR && screen -dmS xon-ka-wa $XON_COMMON sv-dedicated.cfg -sessionid ka-wa +set \_dedimode \"keepaway\" +set \_dedimutator \"weaponarena\" +set \_dedidescription \"Keepaway Weaponarena\"'
alias xon-priv-1='cd $XON_GAMEDIR && screen -dmS xon-priv-1 $XON_COMMON sv-private-1.cfg -sessionid priv-1'
alias xon-priv-2='cd $XON_GAMEDIR && screen -dmS xon-priv-2 $XON_COMMON sv-private-2.cfg -sessionid priv-1'
alias xon-tourney='cd $XON_GAMEDIR && screen -dmS xon-tourney $XON_COMMON sv-tourney.cfg -sessionid tourney'
alias xon-votable='cd $XON_GAMEDIR && screen -dmS xon-votable $XON_COMMON sv-votable.cfg -sessionid votable'
alias xon-spawnweapons='cd $XON_GAMEDIR && screen -dmS xon-spawnweapons $XON_COMMON sv-spawnweapons.cfg -sessionid spawnweapons'

alias xon-irc-eu-ctf-wa='screen -dmS xon-irc-eu-ctf-wa perl rcon2irc.pl $XON_HUBREPO/rcon2irc/hub-eu-ctf-wa.conf'
alias xon-irc-eu-ka-mh='screen -dmS xon-irc-eu-ka-mh perl rcon2irc.pl $XON_HUBREPO/rcon2irc/hub-eu-ka-mh.conf'
alias xon-irc-eu-votable='screen -dmS xon-irc-eu-votable perl rcon2irc.pl $XON_HUBREPO/rcon2irc/hub-eu-votable.conf'
alias xon-irc-na-ctf-wa='screen -dmS xon-irc-na-ctf-wa perl rcon2irc.pl $XON_HUBREPO/rcon2irc/hub-na-ctf-wa.conf'
alias xon-irc-na-ka-mh='screen -dmS xon-irc-na-ka-mh perl rcon2irc.pl $XON_HUBREPO/rcon2irc/hub-na-ka-mh.conf'
alias xon-irc-na-votable='screen -dmS xon-irc-na-votable perl rcon2irc.pl $XON_HUBREPO/rcon2irc/hub-na-votable.conf'
