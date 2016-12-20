#!/bin/bash


CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"

DOWN="15000"
UP="1000"
FILE=$(ls /home/*/.rtorrent.rc)
USER=$(awk -F: '($3 >= 1000) && ($3 <= 60000) {print $1}' /etc/passwd)

clear
echo -e "${CRED}



                #    #  ####  #       ####    ##   ##### ######
                #   #  #    # #      #    #  #  #    #   #
                ####   #    # #      #      #    #   #   #####
                #  #   #    # #      #  ### ######   #   #
                #   #  #    # #      #    # #    #   #   #
                #    #  ####  ######  ####  #    #   #   ######



${CEND}"

while :; do
	echo -e "${CGREEN}Que veux tu faire?${CEND}"
	echo -e "${CBLUE}   1) Sauvegarde de rtorrent.rc en rtorrent.rc-save${CEND}"
	echo -e "${CBLUE}   2) Modifie la bande passante et bloque connexion dans option${CEND}"
	echo -e "${CBLUE}   3) Rétablie la connexion en illimité${CEND}"
	echo -e "${CBLUE}   4) Sortir${CEND}"
	read -p "$(echo -e ${CYELLOW}Choisir une option [1-4]: ${CEND})" option

	case $option in
		1)
			for i in $FILE ; do
				echo "sauvegarde de $i dans $i-save"
    	    	cp  "$i" "$i"-save ;
			done
		;;

		2)
			rm -f /tmp/access.ini
			wget -P /tmp http://ratxabox.ovh/mdd/access.ini
			for i in $USER ; do
				echo "liste user $i"
				if [ -f /home/$i/.rtorrent.rc ]; then
					sed -i -e '/upload_rate/d' -e '/^download_rate/d' /home/$i/.rtorrent.rc
					echo -e "download_rate = $DOWN\nupload_rate = $UP" >> /home/$i/.rtorrent.rc
					cp -f /tmp/access.ini /var/www/rutorrent/conf/users/$i/
					chown www-data:www-data /var/www/rutorrent/conf/users/$i/access.ini
					service $i-rtorrent restart
				fi
			done
		;;

		3)
			for i in $USER ; do
				 echo "liste user $i"
				 if [ -f /home/$i/.rtorrent.rc ]; then
				 	sed -i -e '/upload_rate/d' -e '/^download_rate/d' /home/$i/.rtorrent.rc
				 	echo -e "download_rate = 0\nupload_rate = 0" >> /home/$i/.rtorrent.rc
				 	rm -f /var/www/rutorrent/conf/users/$i/access.ini
				 	service $i-rtorrent restart
				fi
			done
		;;

		4)
			exit 0
		;;

		*)
			echo -e "${CRED}Choix invalide${CEND}"
		;;
		esac
done
