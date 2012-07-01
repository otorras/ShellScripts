#!/bin/sh
# Adapted from https://github.com/pgib/virtualhost.sh
# No point going any farther if we're not running correctly...
if [ `whoami` != 'root' ]; then
	echo "virtualhost.sh requires super-user privileges to work."
	echo "Enter your password to continue..."
	sudo $0 $* || exit 1
fi

if [ $SUDO_USER = "root" ]; then
	/bin/echo "You must start this under your regular user account (not root) using sudo."
	/bin/echo "Rerun using: sudo $0 $*"
	exit 1
fi

APACHE_CONFIG="/private/etc/apache2"
APACHECTL="/usr/sbin/apachectl"

createVirtualHost()
{
  if ! /bin/echo $1 | grep -q -E '\.[A-Za-z]+$'; then
    VIRTUALHOST=$1.dev
  else
    VIRTUALHOST=$1
  fi

	/bin/echo -n "Creating virtual host $VIRTUALHOST... "
	date=`/bin/date`

	cat << __EOF >>$APACHE_CONFIG/extra/httpd-vhosts.conf
# Added $date
<VirtualHost *:80>
	DocumentRoot "$2"
	ServerName $VIRTUALHOST
	<Directory "$2">
		Options Indexes FollowSymLinks
		AllowOverride All
		Order allow,deny
		Allow from all
	</Directory>
</VirtualHost>

__EOF
	/bin/echo "done"

	/bin/echo -n "Adding new entry to hosts file... "
	/bin/echo "127.0.0.1	$VIRTUALHOST" >> /etc/hosts
	/bin/echo "done"

	/bin/echo -n "Restarting Apache... "
	$APACHECTL graceful 1>/dev/null 2>/dev/null
	/bin/echo "done"
}

usage()
{
	/bin/echo "Usage: sudo virtualhost.sh <ServerName> <DocumentRoot>"
	exit 1
}

if [ -z $2 ]; then
	usage
else
	createVirtualHost $1 $2
fi
