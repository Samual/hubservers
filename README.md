hubservers
==========

These scripts and configurations are for the HUB official servers. We release and maintain them openly, and encourage
other people to use and expand upon them for their own servers if they please.

HUB server set up instructions:

Step 1: Confirm prerequisites:
 - Linux server containing build essentials, screen, and git utilities (Ask the owner of the server for dependencies)
 - Shell access to server (Ask the owner of the server)
 - Access to the hubservers github repository (Get a github account and ask Samual)


Step 2: Update the github repository:

 - Pull the latest version of the master branch to your local checkout
 
 - Create a profile configuration for the server you wish to add:
  - 1: Copy configs.pk3dir/profile-default.cfg and rename the suffix to your server name
  - 2: Edit the profile configuration with new information specific to your server:
     - DO NOT add the rcon password here, it will be set in the launching script.
     - Updates you SHOULD make: General server name (NOT INCLUDING MODS OR GAMETYPE),
         server location, server admin name, server admin contact information,
         server provider, server IP (if the host has multiple possible IPs, you must
         provide a specific fixed one so that the server remains on a single address
         consistently), and default curl URL for downloads in that region.

 - Add server entries to the main launching script (control.sh):
  - 1: Inside the "Premade Server Configurations" section of the file, add the launching
       functions for the server instances you wish to add. Follow the instructions inside
       the file to govern argument selection.
  - 2: Inside "Default Server Loadouts" section of the file, check whether
       the server profile already has a function. If it does, add the
       game instances you wish to be running inside the launching function
       for that profile. If it does not, create a separate function for the
       new profile and then add the instances you wish to have running on that
       server to the profile function.
  - 3: For each game instance that you want to have rcon2irc running on a server, also add
       an entry to the xon-irc-start() function. 
         
 - Create an rcon2irc configuration for the game instances you wish to add:
  - 1: Copy one of the configs from the rcon2irc/ folder matching the gametype
       of the game instance you are adding and rename it with this scheme:
     - lowercase: hub-PROVIDER-INSTANCE.conf
  - 2: Edit the rcon2irc configuration with new information specific to the game instance:
     - dp_server should point to the IP and port of the game server instance
     - dp_password should REMAIN AS REPLACEME IN THE GITHUB REPOSITORY... replace with rcon pass on rcon2irc host server
     - irc_server should point to the ZNC instance on the rcon2irc host server. If it is local, use 127.0.0.1:39999
     - irc_password should also remain as example in the github repo, replace with password to ZNC on host server
     - irc_nickprefix should match the following naming scheme:
       - lowercase: twolettercontinent (nospace) gametype (nospace) mutator - like nactfwa
     - irc_nick, irc_nick_alternates, and irc_joinmessage must follow in the same scheme as above
     - dp_server_from_wan must match the HUMAN READABLE address for the server
     - dp_listen_from_server must match the IP to the rcon2irc host server


Step 3: Set up the game server:

 - Sign onto the game server with a user with read/write/execution access to their own directory via SSH
 - Change directory to the home directory of the user
 - Start a git checkout of the hubservers repository from the home directory (the files should load into ~/hubservers/)
 - Start a git checkout of the Xonotic repository from the home directory (the files should load into ~/xonotic/)
   - Follow through the process of setting up Xonotic as demonstrated on http://dev.xonotic.org/projects/xonotic/wiki/Repository_Access
 - Create a symbolic link for the hubserver configurations to be used for the game servers
   - Command (replace USER appropriately): ln -s /home/USER/hubservers/configs.pk3dir /home/USER/.xonotic/data/configs.pk3dir
 - Make it so that control.sh is executable and source it in your bashrc so that the aliases are automatically loaded
   - Add this line to ~/.bashrc: source ~/hubservers/control.sh
 - Execute the above command (source ~/hubservers/control.sh), then execute the following command:
   - xon-update-all
     ^ this will download all the maps and ensure the configs and game are up to date.
 - LOCALLY edit the following files so that they contain the proper settings: (DO NOT PUSH TO GITHUB)
   - ~/hubservers/control.sh: XON_PROFILE with profile name of the current host, XON_PASS with rcon password, XON_RPASS with restricted rcon password
   - ~/hubservers/rcon2irc/hub-PROVIDER-INSTANCE.conf: add the rcon password to the dp_password key if this server will be hosting rcon2irc scripts


Step 4: Start the server:

 - Always run xon-update-all before launching the game servers
 - Execute the following command to launch all game instances for this server: xon-start all
 - If the server hosts the IRC scripts, execute: xon-irc-start
 
 
