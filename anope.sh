#!/bin/bash

# Anope provision script, written by Som
set -e
set -u

_author="Som / somsubhra1 [at] xshellz.com"
_package="Anope"
_version="2.0.6"

dir="services"

echo "Running provision for package $_package version: $_version by $_author"

cd ~

if [ -d $dir ]
then
 echo "$dir is already present in $HOME. Aborting!"
 exit
fi

wget https://github.com/anope/anope/releases/download/2.0.6/anope-2.0.6-source.tar.gz

tar xzvf anope-2.0.6-source.tar.gz

cd anope-2.0.6-source

/usr/bin/expect - <<-EOF
set timeout -1
spawn ./Config
match_max 100000
expect -exact "\[$HOME/services\] "
send -- "\r"
expect -exact "\[y\] "
send -- "\r"
expect -exact "\[\] "
send -- "\r"
expect -exact "\[077\] "
send -- "\r"
expect -exact "\[n\] "
send -- "\r"
expect -exact "\[n\] "
send -- "\r"
expect -exact "\[\] "
send -- "\r"
expect -exact "\[\] "
send -- "\r"
expect -exact "\[\] "
send -- "\r"
expect eof
EOF

cd build

make

make install

cd ~

cd $dir/conf

cat << EOF > services.conf
define
{
	name = "$host"
	value = "$host"
}

#include
{
	type = "file"
	name = "some.conf"
}

#include
{
	type = "executable"
	name = "/usr/bin/wget -q -O - http://some.misconfigured.network.com/services.conf"
}


uplink
{
	/*
	 * The IP or hostname of the IRC server you wish to connect Services to.
	 * Usually, you will want to connect Services over 127.0.0.1 (aka localhost).
	 *
	 * NOTE: On some shell providers, this will not be an option.
	 */
	host = "$ircdip"

	/*
	 * Enable if Services should connect using IPv6.
	 */
	ipv6 = no

	/*
	 * Enable if Services should connect using SSL.
	 * You must have an SSL module loaded for this to work.
	 */
	ssl = no

	/*
	 * The port to connect to.
	 * The IRCd *MUST* be configured to listen on this port, and to accept
	 * server connections.
	 *
	 * Refer to your IRCd documentation for how this is to be done.
	 */
	port = 6667

	/*
	 * The password to send to the IRC server for authentication.
	 * This must match the link block on your IRCd.
	 *
	 * Refer to your IRCd documentation for more information on link blocks.
	 */
	password = "$ircdpass"
}

/*
 * [REQUIRED] Server Information
 *
 * This section contains information about the Services server.
 */
serverinfo
{
	/*
	 * The hostname that Services will be seen as, it must have no conflicts with any
	 * other server names on the rest of your IRC network. Note that it does not have
	 * to be an existing hostname, just one that isn't on your network already.
	 */
	name = "$host"

	/*
	 * The text which should appear as the server's information in /whois and similar
	 * queries.
	 */
	description = "Services for $host"

	/*
	 * The local address that Services will bind to before connecting to the remote
	 * server. This may be useful for multihomed hosts. If omitted, Services will let
	 * the Operating System choose the local address. This directive is optional.
	 *
	 * If you don't know what this means or don't need to use it, just leave this
	 * directive commented out.
	 */
	#localhost = "nowhere."

	/*
	 * What Server ID to use for this connection?
	 * Note: This should *ONLY* be used for TS6/P10 IRCds. Refer to your IRCd documentation
	 * to see if this is needed.
	 */
	#id = "00A"

	/*
	 * The filename containing the Services process ID. The path is relative to the
	 * services root directory.
	 */
	pid = "data/services.pid"

	/*
	 * The filename containing the Message of the Day. The path is relative to the
	 * services root directory.
	 */
	motd = "conf/services.motd"
}

/*
 * [REQUIRED] Protocol module
 *
 * This directive tells Anope which IRCd Protocol to speak when connecting.
 * You MUST modify this to match the IRCd you run.
 *
 * Supported:
 *  - bahamut
 *  - charybdis
 *  - hybrid
 *  - inspircd12
 *  - inspircd20
 *  - ngircd
 *  - plexus
 *  - ratbox
 *  - unreal (for 3.2.x)
 *  - unreal4
 */
module
{
	name = "unreal"

	/*
	 * Some protocol modules can enforce mode locks server-side. This reduces the spam caused by
	 * services immediately reversing mode changes for locked modes.
	 *
	 * If the protocol module you have loaded does not support this, this setting will have no effect.
	 */
	use_server_side_mlock = yes

	/*
	 * Some protocol modules can enforce topic locks server-side. This reduces the spam caused by
	 * services immediately reversing topic changes.
	 *
	 * If the protocol module you have loaded does not support this, this setting will have no effect.
	 */
	use_server_side_topiclock = yes
}

/*
 * [REQUIRED] Network Information
 *
 * This section contains information about the IRC network that Services will be
 * connecting to.
 */
networkinfo
{
	/*
	 * This is the name of the network that Services will be running on.
	 */
	networkname = "$host"

	/*
	 * Set this to the maximum allowed nick length on your network.
	 * Be sure to set this correctly, as setting this wrong can result in
	 * Services being disconnected from the network.
	 */
	nicklen = 31

	/* Set this to the maximum allowed ident length on your network.
	 * Be sure to set this correctly, as setting this wrong can result in
	 * Services being disconnected from the network.
	 */
	userlen = 10

	/* Set this to the maximum allowed hostname length on your network.
	 * Be sure to set this correctly, as setting this wrong can result in
	 * Services being disconnected from the network.
	 */
	hostlen = 64

	/* Set this to the maximum allowed channel length on your network.
	 */
	chanlen = 32

	/* The maximum number of list modes settable on a channel (such as b, e, I).
	 * Comment out or set to 0 to disable.
	 */
	modelistsize = 100

	/*
	 * Characters allowed in nicknames. This always includes the characters described
	 * in RFC1459, and so does not need to be set for normal behavior. Changing this to
	 * include characters your IRCd doesn't support will cause your IRCd and/or Services
	 * to break. Multibyte characters are not supported, nor are escape sequences.
	 *
	 * It is recommended you DON'T change this.
	 */
	#nick_chars = ""

	/*
	 * The characters allowed in hostnames. This is used for validating hostnames given
	 * to services, such as BotServ bot hostnames and user vhosts. Changing this is not
	 * recommended unless you know for sure your IRCd supports whatever characters you are
	 * wanting to use. Telling services to set a vHost containing characters your IRCd
	 * disallows could potentially break the IRCd and/or Services.
	 *
	 * It is recommended you DON'T change this.
	 */
	vhost_chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-"

	/*
	 * If set to true, allows vHosts to not contain dots (.).
	 * Newer IRCds generally do not have a problem with this, but the same warning as
	 * vhost_chars applies.
	 *
	 * It is recommended you DON'T change this.
	 */
	allow_undotted_vhosts = false

	/*
	 * The characters that are not allowed to be at the very beginning or very ending
	 * of a vHost. The same warning as vhost_chars applies.
	 *
	 * It is recommended you DON'T change this.
	 */
	disallow_start_or_end = ".-"
}

/*
 * [REQUIRED] Services Options
 *
 * This section contains various options which determine how Services will operate.
 */
options
{
	/*
	 * On Linux/UNIX systems Anope can setuid and setgid to this user and group
	 * after starting up. This is useful if Anope has to bind to privileged ports
	 */
	#user = "anope"
	#group = "anope"

	/*
	 * The case mapping used by services. This must be set to a valid locale name
	 * installed on your machine. Services use this case map to compare, with
	 * case insensitivity, things such as nick names, channel names, etc.
	 *
	 * We provide two special casemaps shipped with Anope, ascii and rfc1459.
	 *
	 * This value should be set to what your IRCd uses, which is probably rfc1459,
	 * however Anope has always used ascii for comparison, so the default is ascii.
	 *
	 * Changing this value once set is not recommended.
	 */
	casemap = "ascii"

	/*
	 * This key is used to initiate the random number generator. This number
	 * MUST be random as you want your passcodes to be random. Don't give this
	 * key to anyone! Keep it private!
	 *
	 * NOTE: If you don't uncomment this or keep the default values, any talented
	 * programmer would be able to easily "guess" random strings used to mask
	 * information. Be safe, and come up with a 7-digit number.
	 *
	 * This directive is optional, but highly recommended.
	 */
	#seed = 9866235

	/*
	 * If set, Services will perform more stringent checks on passwords. If this
	 * isn't set, Services will only disallow a password if it is the same as the
	 * entity (nickname name) with which it is associated. When set, however,
	 * Services will also check that the password is at least five
	 * characters long, and in the future will probably check other things
	 * as well.
	 *
	 * This directive is optional, but recommended.
	 */
	strictpasswords = yes

	/*
	 * Sets the number of invalid password tries before Services removes a user
	 * from the network. If a user enters a number of invalid passwords equal to
	 * the given amount for any Services function or combination of functions
	 * during a single IRC session (subject to badpasstimeout, below), Services
	 * will issues a /KILL for the user. If not given, Services will ignore
	 * failed password attempts (though they will be logged in any case).
	 *
	 * This directive is optional, but recommended.
	 */
	badpasslimit = 5

	/*
	 * Sets the time after which invalid passwords are forgotten about. If a user
	 * does not enter any incorrect passwords in this amount of time, the incorrect
	 * password count will reset to zero. If not given, the timeout will be
	 * disabled, and the incorrect password count will never be reset until the user
	 * disconnects.
	 *
	 * This directive is optional.
	 */
	badpasstimeout = 1h

	/*
	 * Sets the delay between automatic database updates.
	 */
	updatetimeout = 5m

	/*
	 * Sets the delay between checks for expired nicknames and channels.
	 */
	expiretimeout = 30m

	/*
	 * Sets the timeout period for reading from the uplink.
	 */
	readtimeout = 5s

	/*
	 * Sets the interval between sending warning messages for program errors via
	 * WALLOPS/GLOBOPS.
	 */
	warningtimeout = 4h

	/*
	 * Sets the (maximum) frequency at which the timeout list is checked. This,
	 * combined with readtimeout above, determines how accurately timed events,
	 * such as nick kills, occur; it also determines how much CPU time Services
	 * will use doing this. Higher values will cause less accurate timing but
	 * less CPU usage.
	 *
	 * Note that this value is not an absolute limit on the period between
	 * checks of the timeout list; the previous may be as great as readtimeout
	 * (above) during periods of inactivity.
	 *
	 * If this directive is not given, it will default to 0.
	 */
	timeoutcheck = 3s

	/*
	 * If set, this will allow users to let Services send PRIVMSGs to them
	 * instead of NOTICEs. Also see the "msg" option of nickserv:defaults,
	 * which also toggles the default communication (PRIVMSG or NOTICE) to
	 * use for unregistered users.
	 *
	 * This is a feature that is against the IRC RFC and should be used ONLY
	 * if absolutely necessary.
	 *
	 * This directive is optional, and not recommended.
	 */
	#useprivmsg = yes

	/*
	 * If set, will force Services to only respond to PRIVMSGs addresses to
	 * Nick@ServerName - e.g. NickServ@localhost.net. This should be used in
	 * conjunction with IRCd aliases. This directive is optional.
	 *
	 * This option will have no effect on some IRCds, such as TS6 IRCds.
	 */
	#usestrictprivmsg = yes

	/*
	 * If set, Services will only show /stats o to IRC Operators. This directive
	 * is optional.
	 */
	#hidestatso = yes

	/*
	 * A space-separated list of ulined servers on your network, it is assumed that
	 * the servers in this list are allowed to set channel modes and Services will
	 * not attempt to reverse their mode changes.
	 *
	 * WARNING: Do NOT put your normal IRC user servers in this directive.
	 *
	 * This directive is optional.
	 */
	#ulineservers = "stats.your.network"

	/*
	 * How long to wait between connection retries with the uplink(s).
	 */
	retrywait = 60s

	/*
	 * If set, Services will hide commands that users don't have the privilege to execute
	 * from HELP output.
	 */
	hideprivilegedcommands = yes

	/*
	 * If set, Services will hide commands that users can't execute because they are not
	 * logged in from HELP output.
	 */
	hideregisteredcommands = yes

	/* The regex engine to use, as provided by the regex modules.
	 * Leave commented to disable regex matching.
	 *
	 * Note for this to work the regex module providing the regex engine must be loaded.
	 */
	#regexengine = "regex/pcre"

	/*
	 * A list of languages to load on startup that will be available in /nickserv set language.
	 * Useful if you translate Anope to your language. (Explained further in docs/LANGUAGE).
	 * Note that english should not be listed here because it is the base language.
	 *
	 * Removing .UTF-8 will instead use the default encoding for the language, eg. iso-8859-1 for western European languages.
	 */
	languages = "ca_ES.UTF-8 de_DE.UTF-8 el_GR.UTF-8 es_ES.UTF-8 fr_FR.UTF-8 hu_HU.UTF-8 it_IT.UTF-8 nl_NL.UTF-8 pl_PL.UTF-8 pt_PT.UTF-8 ru_RU.UTF-8 tr_TR.UTF-8"

	/*
	 * Default language that non- and newly-registered nicks will receive messages in.
	 * Set to "en" to enable English. Defaults to the language the system uses.
	 */
	#defaultlanguage = "es_ES.UTF-8"
}

/*
 * [OPTIONAL] BotServ
 *
 * Includes botserv.example.conf, which is necessary for BotServ functionality.
 *
 * Remove this block to disable BotServ.
 */
include
{
	type = "file"
	name = "botserv.example.conf"
}

/*
 * [RECOMMENDED] ChanServ
 *
 * Includes chanserv.example.conf, which is necessary for ChanServ functionality.
 *
 * Remove this block to disable ChanServ.
 */
include
{
	type = "file"
	name = "chanserv.example.conf"
}

/*
 * [RECOMMENDED] Global
 *
 * Includes global.example.conf, which is necessary for Global functionality.
 *
 * Remove this block to disable Global.
 */
include
{
	type = "file"
	name = "global.example.conf"
}

/*
 * [OPTIONAL] HostServ
 *
 * Includes hostserv.example.conf, which is necessary for HostServ functionality.
 *
 * Remove this block to disable HostServ.
 */
include
{
	type = "file"
	name = "hostserv.example.conf"
}

/*
 * [OPTIONAL] MemoServ
 *
 * Includes memoserv.example.conf, which is necessary for MemoServ functionality.
 *
 * Remove this block to disable MemoServ.
 */
include
{
	type = "file"
	name = "memoserv.example.conf"
}

/*
 * [OPTIONAL] NickServ
 *
 * Includes nickserv.example.conf, which is necessary for NickServ functionality.
 *
 * Remove this block to disable NickServ.
 */
include
{
	type = "file"
	name = "nickserv.example.conf"
}

/*
 * [RECOMMENDED] OperServ
 *
 * Includes operserv.example.conf, which is necessary for OperServ functionality.
 *
 * Remove this block to disable OperServ.
 */
include
{
	type = "file"
	name = "operserv.example.conf"
}

/*
 * [RECOMMENDED] Logging Configuration
 *
 * This section is used for configuring what is logged and where it is logged to.
 * You may have multiple log blocks if you wish. Remember to properly secure any
 * channels you choose to have Anope log to!
 */
log
{
	/*
	 * Target(s) to log to, which may be one of the following:
	 *   - a channel name
	 *   - a filename
	 *   - globops
	 */
	target = "services.log"

	/* Log to both services.log and the channel #services
	 *
	 * Note that some older IRCds, such as Ratbox, require services to be in the
	 * log channel to be able to message it. To do this, configure service:channels to
	 * join your logging channel.
	 */
	#target = "services.log #services"

	/*
	 * The source(s) to only accept log messages from. Leave commented to allow all sources.
	 * This can be a users name, a channel name, one of our clients (eg, OperServ), or a server name.
	 */
	#source = ""

	/*
	 * The bot used to log generic messages which have no predefined sender if there
	 * is a channel in the target directive.
	 */
	bot = "Global"

	/*
	 * The number of days to keep logfiles, only useful if you are logging to a file.
	 * Set to 0 to never delete old logfiles.
	 *
	 * Note that Anope must run 24 hours a day for this feature to work correctly.
	 */
	logage = 7

	/*
	 * What types of log messages should be logged by this block. There are nine general categories:
	 *
	 *  admin      - Execution of admin commands (OperServ, etc).
	 *  override   - A services operator using their powers to execute a command they couldn't normally.
	 *  commands   - Execution of general commands.
	 *  servers    - Server actions, linking, squitting, etc.
	 *  channels   - Actions in channels such as joins, parts, kicks, etc.
	 *  users      - User actions such as connecting, disconnecting, changing name, etc.
	 *  other      - All other messages without a category.
	 *  rawio      - Logs raw input and output from services
	 *  debug      - Debug messages (log files can become VERY large from this).
	 *
	 * These options determine what messages from the categories should be logged. Wildcards are accepted, and
	 * you can also negate values with a ~. For example, "~operserv/akill operserv/*" would log all operserv
	 * messages except for operserv/akill. Note that processing stops at the first matching option, which
	 * means "* ~operserv/*" would log everything because * matches everything.
	 *
	 * Valid admin, override, and command options are:
	 *    pesudo-serv/commandname (eg, operserv/akill, chanserv/set)
	 *
	 * Valid server options are:
	 *    connect, quit, sync, squit
	 *
	 * Valid channel options are:
	 *    create, destroy, join, part, kick, leave, mode
	 *
	 * Valid user options are:
	 *    connect, disconnect, quit, nick, ident, host, mode, maxusers, oper, away
	 *
	 * Rawio and debug are simple yes/no answers, there are no types for them.
	 *
	 * Note that modules may add their own values to these options.
	 */
	admin = "*"
	override = "chanserv/* nickserv/* memoserv/set ~botserv/set botserv/*"
	commands = "~operserv/* *"
	servers = "*"
	#channels = "~mode *"
	users = "connect disconnect nick"
	other = "*"
	rawio = no
	debug = no
}

/*
 * A log block to globops some useful things.
 */
log
{
	target = "globops"
	admin = "global/* operserv/chankill operserv/mode operserv/kick operserv/akill operserv/s*line operserv/noop operserv/jupe operserv/oline operserv/set operserv/svsnick operserv/svsjoin operserv/svspart nickserv/getpass */drop"
	servers = "squit"
	users = "oper"
	other = "expire/* bados akill/*"
}

/*
 * [RECOMMENDED] Oper Access Config
 *
 * This section is used to set up staff access to restricted oper only commands.
 * You may define groups of commands and privileges, as well as who may use them.
 *
 * This block is recommended, as without it you will be unable to access most oper commands.
 * It replaces the old ServicesRoot directive amongst others.
 *
 * The command names below are defaults and are configured in the *serv.conf's. If you configure
 * additional commands with permissions, such as commands from third party modules, the permissions
 * must be included in the opertype block before the command can be used.
 *
 * Available privileges:
 *  botserv/administration        - Can view and assign private BotServ bots
 *  botserv/fantasy               - Can use fantasy commands without the FANTASIA privilege
 *  chanserv/administration       - Can modify the settings of any channel (including changing of the owner!)
 *  chanserv/access/list          - Can view channel access and akick lists, but not modify them
 *  chanserv/access/modify        - Can modify channel access and akick lists, and use /chanserv enforce
 *  chanserv/auspex               - Can see any information with /chanserv info
 *  chanserv/no-register-limit    - May register an unlimited number of channels and nicknames
 *  chanserv/kick                 - Can kick and ban users from channels through ChanServ
 *  memoserv/info                 - Can see any information with /memoserv info
 *  memoserv/set-limit            - Can set the limit of max stored memos on any user and channel
 *  memoserv/no-limit             - Can send memos through limits and throttles
 *  nickserv/access               - Can modify other users access and certificate lists
 *  nickserv/alist                - Can see the channel access list of other users
 *  nickserv/auspex               - Can see any information with /nickserv info
 *  nickserv/confirm              - Can confirm other users nicknames
 *  nickserv/drop                 - Can drop other users nicks
 *  operserv/config               - Can modify services's configuration
 *  operserv/oper/modify          - Can add and remove operators with at most the same privileges
 *  protected                     - Can not be kicked from channels by Services
 *
 * Available commands:
 *   botserv/bot/del          botserv/bot/add               botserv/bot/change        botserv/set/private
 *   botserv/set/nobot
 *
 *   chanserv/drop            chanserv/getkey               chanserv/invite
 *   chanserv/list            chanserv/suspend              chanserv/topic
 *
 *   chanserv/saset/noexpire
 *
 *   memoserv/sendall        memoserv/staff
 *
 *   nickserv/getpass        nickserv/getemail      nickserv/suspend      nickserv/ajoin
 *   nickserv/list
 *
 *   nickserv/saset/autoop     nickserv/saset/email   nickserv/saset/greet     nickserv/saset/password
 *   nickserv/saset/display    nickserv/saset/kill    nickserv/saset/language  nickserv/saset/message
 *   nickserv/saset/private    nickserv/saset/secure  nickserv/saset/url       nickserv/saset/noexpire
 *   nickserv/saset/keepmodes
 *
 *   hostserv/set            hostserv/del           hostserv/list
 *
 *   global/global
 *
 *   operserv/news         operserv/stats        operserv/kick       operserv/exception    operserv/seen
 *   operserv/mode         operserv/session      operserv/modinfo    operserv/ignore       operserv/chanlist
 *   operserv/chankill     operserv/akill        operserv/sqline     operserv/snline       operserv/userlist
 *   operserv/oper         operserv/config       operserv/umode      operserv/logsearch
 *   operserv/modload      operserv/jupe         operserv/set        operserv/noop
 *   operserv/quit         operserv/update       operserv/reload     operserv/restart
 *   operserv/shutdown     operserv/svs          operserv/oline      operserv/kill
 *
 * Firstly, we define 'opertypes' which are named whatever we want ('Network Administrator', etc).
 * These can contain commands for oper-only strings (see above) which grants access to that specific command,
 * and privileges (which grant access to more general permissions for the named area).
 * Wildcard entries are permitted for both, e.g. 'commands = "operserv/*"' for all OperServ commands.
 *
 * Below are some default example types, but this is by no means exhaustive,
 * and it is recommended that you configure them to your needs.
 */

opertype
{
	/* The name of this opertype */
	name = "Helper"

	/* What commands (see above) this opertype has */
	commands = "hostserv/*"
}

opertype
{
	/* The name of this opertype */
	name = "Services Operator"

	/* What opertype(s) this inherits from. Separate with a comma. */
	inherits = "Helper, Another Helper"

	/* What commands (see above) this opertype may use */
	commands = "chanserv/list chanserv/suspend chanserv/topic memoserv/staff nickserv/list nickserv/suspend operserv/mode operserv/chankill operserv/akill operserv/session operserv/modinfo operserv/sqline operserv/oper operserv/kick operserv/ignore operserv/snline"

	/* What privs (see above) this opertype has */
	privs = "chanserv/auspex chanserv/no-register-limit memoserv/* nickserv/auspex nickserv/confirm"

	/*
	 * Modes to be set on users when they identify to accounts linked to this opertype.
	 *
	 * This can be used to automatically oper users who identify for services operator accounts, and is
	 * useful for setting modes such as Plexus's user mode +N.
	 *
	 * Note that some IRCds, such as InspIRCd, do not allow directly setting +o, and this will not work.
	 */
	#modes = "+o"
}

opertype
{
	name = "Services Administrator"

	inherits = "Services Operator"

	commands = "botserv/* chanserv/access/list chanserv/drop chanserv/getkey chanserv/saset/noexpire memoserv/sendall nickserv/saset/* nickserv/getemail operserv/news operserv/jupe operserv/svs operserv/stats operserv/oline operserv/noop operserv/forbid global/*"

	privs = "*"
}

opertype
{
	name = "Services Root"

	commands = "*"

	privs = "*"
}

/*
 * After defining different types of operators in the above opertype section, we now define who is in these groups
 * through 'oper' blocks, similar to ircd access.
 *
 * The default is to comment these out (so NOBODY will have Services access).
 * You probably want to add yourself and a few other people at minimum.
 *
 * As with all permissions, make sure to only give trustworthy people access to Services.
 */

oper
{
	/* The nickname of this services oper */
	name = "$opername"

	/* The opertype this person will have */
	type = "Services Root"

	/* If set, the user must be an oper on the IRCd to gain their Services
	 * oper privileges.
	 */
	require_oper = yes

	/* An optional password. If defined the user must login using "/msg OperServ LOGIN" first */
	#password = "secret"

	/* An optional SSL fingerprint. If defined, it's required to be able to use this opertype. */
	#certfp = "ed3383b3f7d74e89433ddaa4a6e5b2d7"

	/* An optional list of user@host masks. If defined the user must be connected from one of them */
	#host = "*@*.anope.org ident@*"

	/* An optional vHost to set on users who identify for this oper block.
	 * This will override HostServ vHosts, and may not be available on all IRCds
	 */
	#vhost = "oper.mynet"
}

#oper
{
	name = "nick2"
	type = "Services Administrator"
}

#oper
{
	name = "nick3"
	type = "Helper"
}

/*
 * [OPTIONAL] Mail Config
 *
 * This section contains settings related to the use of e-mail from Services.
 * If the usemail directive is set to yes, unless specified otherwise, all other
 * directives are required.
 *
 * NOTE: Users can find the IP of the machine services is running on by examining
 * mail headers. If you do not want your IP known, you should set up a mail relay
 * to strip the relevant headers.
 */
mail
{
	/*
	 * If set, this option enables the mail commands in Services. You may choose
	 * to disable it if you have no Sendmail-compatible mailer installed. Whilst
	 * this directive (and entire block) is optional, it is required if
	 * nickserv:registration is set to yes.
	 */
	usemail = yes

	/*
	 * This is the command-line that will be used to call the mailer to send an
	 * e-mail. It must be called with all the parameters needed to make it
	 * scan the mail input to find the mail recipient; consult your mailer
	 * documentation.
	 *
	 * Postfix users must use the compatible sendmail utility provided with
	 * it. This one usually needs no parameters on the command-line. Most
	 * sendmail applications (or replacements of it) require the -t option
	 * to be used.
	 */
	sendmailpath = "/usr/sbin/sendmail -t"

	/*
	 * This is the e-mail address from which all the e-mails are to be sent from.
	 * It should really exist.
	 */
	sendfrom = "services@localhost.net"

	/*
	 * This controls the minimum amount of time a user must wait before sending
	 * another e-mail after they have sent one. It also controls the minimum time
	 * a user must wait before they can receive another e-mail.
	 *
	 * This feature prevents users from being mail bombed using Services and
	 * it is highly recommended that it be used.
	 *
	 * This directive is optional, but highly recommended.
	 */
	delay = 5m

	/*
	 * If set, Services will not attempt to put quotes around the TO: fields
	 * in e-mails.
	 *
	 * This directive is optional, and as far as we know, it's only needed
	 * if you are using ESMTP or QMail to send out e-mails.
	 */
	#dontquoteaddresses = yes

	/*
	 * The subject and message of emails sent to users when they register accounts.
	 */
	registration_subject = "Nickname registration for %n"
	registration_message = "Hi,

				You have requested to register the nickname %n on %N.
				Please type \" /msg NickServ CONFIRM %c \" to complete registration.

				If you don't know why this mail was sent to you, please ignore it silently.

				%N administrators."

	/*
	 * The subject and message of emails sent to users when they request a new password.
	 */
	reset_subject = "Reset password request for %n"
	reset_message = "Hi,

			You have requested to have the password for %n reset.
			To reset your password, type \" /msg NickServ CONFIRM %n %c \"

			If you don't know why this mail was sent to you, please ignore it silently.

			%N administrators."

	/*
	 * The subject and message of emails sent to users when they request a new email address.
	 */
	emailchange_subject = "Email confirmation"
	emailchange_message = "Hi,

			You have requested to change your email address from %e to %E.
			Please type \" /msg NickServ CONFIRM %c \" to confirm this change.

			If you don't know why this mail was sent to you, please ignore it silently.

			%N administrators."

	/*
	 * The subject and message of emails sent to users when they receive a new memo.
	 */
	memo_subject = "New memo"
	memo_message = "Hi %n,

			You've just received a new memo from %s. This is memo number %d.

			Memo text:

			%t"
}

/*
 * [REQUIRED] Database configuration.
 *
 * This section is used to configure databases used by Anope.
 * You should at least load one database method, otherwise any data you
 * have will not be stored!
 */

/*
 * [DEPRECATED] db_old
 *
 * This is the old binary database format from late Anope 1.7.x, Anope 1.8.x, and
 * early Anope 1.9.x. This module only loads these databases, and will NOT save them.
 * You should only use this to upgrade old databases to a newer database format by loading
 * other database modules in addition to this one, which will be used when saving databases.
 */
#module
{
	name = "db_old"

	/*
	 * This is the encryption type used by the databases. This must be set correctly or
	 * your passwords will not work. Valid options are: md5, oldmd5, sha1, and plain.
	 * You must also be sure to load the correct encryption module below in the Encryption
	 * Modules section so that your passwords work.
	 */
	#hash = "md5"
}

/*
 * [RECOMMENDED] db_flatfile
 *
 * This is the default flatfile database format.
 */
module
{
	name = "db_flatfile"

	/*
	 * The database name db_flatfile should use
	 */
	database = "anope.db"

	/*
	 * Sets the number of days backups of databases are kept. If you don't give it,
	 * or if you set it to 0, Services won't backup the databases.
	 *
	 * NOTE: Services must run 24 hours a day for this feature to work.
	 *
	 * This directive is optional, but recommended.
	 */
	keepbackups = 3

	/*
	 * Allows Services to continue file write operations (i.e. database saving)
	 * even if the original file cannot be backed up. Enabling this option may
	 * allow Services to continue operation under conditions where it might
	 * otherwise fail, such as a nearly-full disk.
	 *
	 * NOTE: Enabling this option can cause irrecoverable data loss under some
	 * conditions, so make CERTAIN you know what you're doing when you enable it!
	 *
	 * This directive is optional, and you are discouraged against enabling it.
	 */
	#nobackupokay = yes

	/*
	 * If enabled, services will fork a child process to save databases.
	 *
	 * This is only useful with very large databases, with hundreds
	 * of thousands of objects, that have a noticeable delay from
	 * writing databases.
	 *
	 * If your database is large enough cause a noticeable delay when
	 * saving you should consider a more powerful alternative such
	 * as db_sql or db_redis, which incrementally update their
	 * databases asynchronously in real time.
	 */
	fork = no
}

/*
 * db_sql and db_sql_live
 *
 * db_sql module allows saving and loading databases using one of the SQL engines.
 * This module loads the databases once on startup, then incrementally updates
 * objects in the database as they are changed within Anope in real time. Changes
 * to the SQL tables not done by Anope will have no effect and will be overwritten.
 *
 * db_sql_live module allows saving and loading databases using one of the SQL engines.
 * This module reads and writes to SQL in real time. Changes to the SQL tables
 * will be immediately reflected into Anope. This module should not be loaded
 * in conjunction with db_sql.
 *
 */
#module
{
	name = "db_sql"
	#name = "db_sql_live"

	/*
	 * The SQL service db_sql(_live) should use, these are configured in modules.conf.
	 * For MySQL, this should probably be mysql/main.
	 */
	engine = "sqlite/main"

	/*
	 * An optional prefix to prepended to the name of each created table.
	 * Do not use the same prefix for other programs.
	 */
	#prefix = "anope_db_"

	/* Whether or not to import data from another database module in to SQL on startup.
	 * If you enable this, be sure that the database services is configured to use is
	 * empty and that another database module to import from is loaded before db_sql.
	 * After you enable this and do a database import you should disable it for
	 * subsequent restarts.
	 *
	 * Note that you can not import databases using db_sql_live. If you want to import
	 * databases and use db_sql_live you should import them using db_sql, then shut down
	 * and start services with db_sql_live.
	 */
	import = false
}

/*
 * db_redis.
 *
 * This module allows using Redis (http://redis.io) as a database backend.
 * This module requires that m_redis is loaded and configured properly.
 *
 * Redis 2.8 supports keyspace notifications which allows Redis to push notifications
 * to Anope about outside modifications to the database. This module supports this and
 * will internally reflect any changes made to the database immediately once notified.
 * See docs/REDIS for more information regarding this.
 */
#module
{
	name = "db_redis"

	/*
	 * Redis database to use. This must be configured with m_redis.
	 */
	engine = "redis/main"
}

/*
 * [RECOMMENDED] Encryption modules.
 *
 * The encryption modules are used when dealing with passwords. This determines how
 * the passwords are stored in the databases, and does not add any security as
 * far as transmitting passwords over the network goes.
 *
 * Without any encryption modules loaded users will not be able to authenticate unless
 * there is another module loaded that provides authentication checking, such as
 * m_ldap_authentication or m_sql_authentication.
 *
 * With enc_none, passwords will be stored in plain text, allowing for passwords
 * to be recovered later but it isn't secure and therefore is not recommended.
 *
 * The other encryption modules use one-way encryption, so the passwords can not
 * be recovered later if those are used.
 *
 * The first encryption module loaded is the primary encryption module. All new passwords are
 * encrypted by this module. Old passwords stored in another encryption method are
 * automatically re-encrypted by the primary encryption module on next identify.
 *
 * enc_md5, enc_sha1, and enc_old are deprecated, and are provided for users
 * to upgrade to a newer encryption module. Do not use them as the primary
 * encryption module. They will be removed in a future release.
 *
 */

#module { name = "enc_bcrypt" }
module { name = "enc_sha256" }

/*
 * When using enc_none, passwords will be stored without encryption. This isn't secure
 * therefore it is not recommended.
 */
#module { name = "enc_none" }

/* Deprecated encryption modules */
#module { name = "enc_md5" }
#module { name = "enc_sha1" }

/*
 * enc_old is Anope's previous (broken) MD5 implementation used from 1.4.x to 1.7.16.
 * If your databases were made using that module, load it here to allow conversion to the primary
 * encryption method.
 */
#module { name = "enc_old" }


/* Extra (optional) modules. */
include
{
	type = "file"
	name = "modules.example.conf"
}

/*
 * Chanstats module.
 * Requires a MySQL Database.
 */
#include
{
	type = "file"
	name = "chanstats.example.conf"
}

/*
 * IRC2SQL Gateway
 * This module collects data about users, channels and servers. It doesn't build stats
 * itself, however, it gives you the database, it's up to you how you use it.
 *
 * Requires a MySQL Database and MySQL version 5.5 or higher
 */
#include
{
	type = "file"
	name = "irc2sql.example.conf"
}
EOF

echo "Created services.conf. Attempting to start Anope..."

cd ~

cd $dir/bin

./services

if pgrep services >/dev/null 2>&1
then
 echo "Services is running successfully"
else
 echo "Error occured"
 exit 
fi
echo "Provision done, successfully."