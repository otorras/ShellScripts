#!/bin/sh
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

/bin/echo "Adding virtual host $1"

date=`/bin/date`

cat << __EOF >>$APACHE_CONFIG/extra/httpd-vhosts.conf
# Added $date
<VirtualHost *:80>
  DocumentRoot "$2"
  ServerName $1
  <Directory "$2">
    Options All
    AllowOverride All
    Order allow,deny
    Allow from all
  </Directory>
</VirtualHost>

__EOF

/bin/echo "Updating hosts"

cat << __EOF >>/etc/hosts
127.0.0.1 $1
__EOF

/bin/echo -n "Restarting Apache... "
$APACHECTL graceful 1>/dev/null 2>/dev/null
/bin/echo "done"
