#!/bin/bash
#Author: kolgate
#Credits: xavier warezcmpt
# variables couleurs
CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"
clear
echo -e "${CRED}



                #    #  ####  #       ####    ##   ##### ######
                #   #  #    # #      #    #  #  #    #   #
                ####   #    # #      #      #    #   #   #####
                #  #   #    # #      #  ### ######   #   #
                #   #  #    # #      #    # #    #   #   #
                #    #  ####  ######  ####  #    #   #   ######



${CEND}"

echo -e "${CGREEN} http://www.kolgate.xyz $CEND "
echo -e "${CGREEN} Email: kolgate@kolgate.xyz $CEND "
echo -e "${CGREEN} Author: kolgate $CEND "
echo -e "${CGREEN} Credits:xavier warezcmpt $CEND "
echo -e "${CGREEN} Version: 1.0 $CEND "

# controle droits utilisateur
if [ $(id -u) -ne 0 ]; then
echo -e "${CRED} Sorry only root user can install elFinder $CEND"
exit 1
fi

#Test bonobox
folder="/var/www/base"
if [ ! -d "$folder" ] ; then
	echo -e "${CRED} Sorry it's only for Bonobox $CEND"
	exit 1
fi

#IP Server
IPserver=$(wget -qO- ipv4.icanhazip.com)

#IP home
IPhome=$(ifconfig | grep "inet ad" | cut -f2 -d: | awk '{print $1}' | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

echo "ip serveur "$IPserver" ip privee "$IPhome""

#Php Version bonobox includes/deb.sh
php=$(php -v | grep -o -E '[0-9]+' | head -1 | sed -e 's/^0\+//')

if [ "$php" -eq "5" ]; then
	PHPPATH="/etc/php5"
	PHPNAME="php5"
	PHPSOCK="/var/run/php5-fpm.sock"
elif [ "$php" -eq "7" ]; then
	PHPPATH="/etc/php/7.0"
	PHPNAME="php7.0"
	PHPSOCK="/var/run/php/php7.0-fpm.sock"
else
	echo -e "${CRED} OUPS something went wrong with Bonobox install $CEND"
	echo -e "${CRED} please do it again... $CEND"
	exit 1
fi

rm /var/www/base/config_elFinder.txt

echo "Subject: elFinder Install <br>
Ip Server: $IPserver <br>
IP Home: $IPhome <br>
Email: $email <br>" >> /var/www/base/config_elFinder.txt

if [ ! -d "/var/www/elFinder" ]; then
	##git
	sudo apt-get install git
	cd /var/www/ || exit 1
	git clone https://github.com/Studio-42/elFinder.git
	cp elFinder/php/connector.minimal.php-dist elFinder/php/connector.minimal.php
	cp -f /etc/nginx/sites-enabled/rutorrent.conf /etc/nginx/sites-enabled/rutorrent.old

sed -i '$d' /etc/nginx/sites-enabled/rutorrent.conf
echo "location ^~ /elFinder {
        auth_basic \"access\";
        auth_basic_user_file \"/etc/nginx/passwd/rutorrent_passwd\";
        root /var/www;
        include /etc/nginx/conf.d/php.conf;
		include /etc/nginx/conf.d/cache.conf;
        index \$remote_user.elfinder.src.html;
	}
}" >> /etc/nginx/sites-enabled/rutorrent.conf

service nginx restart && service "$PHPNAME"-fpm restart
fi

echo -e "${CYELLOW} elFinder is installed for all $CEND"

echo -e "${CYELLOW} Do you want to install elFinder for all users? (y/n) $CEND"
read yn
if [ $yn  == "y" ] ; then
	cd /var/www/rutorrent/conf/users
		for dir in *; do
		echo "$dir"
		elFinderuser="$dir"
			if [ ! -f "/var/www/elFinder/$elFinderuser.elfinder.src.html" ]; then
				mkdir /var/www/elFinder/$elFinderuser
				cp /var/www/elFinder/elfinder.src.html /var/www/elFinder/$elFinderuser.elfinder.src.html
				sed -i -e "s/minimal/$elFinderuser/g" /var/www/elFinder/$elFinderuser.elfinder.src.html
				cp /var/www/elFinder/php/connector.minimal.php /var/www/elFinder/php/connector.$elFinderuser.php
				sed -i -e "s/.\/files/.\/$elFinderuser/g" /var/www/elFinder/php/connector.$elFinderuser.php
				ln -s /home/$elFinderuser/torrents /var/www/elFinder/$elFinderuser/torrents
				chown -R  $elFinderuser:www-data /home/$elFinderuser/torrents
				chmod -R 2775 /home/$elFinderuser/torrents
			fi
		done
fi

service nginx restart && service "$PHPNAME"-fpm restart
echo "elFinder: http://www.$IPserver/elFinder/ <br>" >> /var/www/base/config_elFinder.txt
