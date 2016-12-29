#!/bin/bash


CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"


FILE=$(ls /home/*/.rtorrent.rc)
USER=$(awk -F: '($3 >= 1000) && ($3 <= 60000) {print $1}' /etc/passwd)
LOPT="pieces.memory.max.set network.http.max_open.set network.max_open_files.set max_downloads_global"


DOWNUP()
{
	if [ -f /home/$1/.rtorrent.rc ]; then
		sed -i -e '/upload_rate/d' -e '/^download_rate/d'  /home/$1/.rtorrent.rc
		echo -e "download_rate = $DOWN\nupload_rate = $UP" >> /home/$1/.rtorrent.rc
		cp -f /tmp/access.ini /var/www/rutorrent/conf/users/$1/
		chown www-data:www-data /var/www/rutorrent/conf/users/$1/access.ini
		service $1-rtorrent restart
	fi
}

DOWNUPZ()
{
	if [ -f /home/$i/.rtorrent.rc ]; then
		sed -i -e '/upload_rate/d' -e '/^download_rate/d'  /home/$1/.rtorrent.rc
	 	echo -e "download_rate = 0\nupload_rate = 0" >> /home/$1/.rtorrent.rc
	 	rm -f /var/www/rutorrent/conf/users/$1/access.ini
	 	service $1-rtorrent restart
	fi
}

LUSER()
{
	for i in $USER ; do
				 echo "liste des users : $i"
				 DOWNUPZ "$i"
			done
}

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
	echo -e "${CBLUE}   2) Modifie la bande passante et bloque les options${CEND}"
	echo -e "${CBLUE}   3) Rétablie la connexion en illimité${CEND}"
	echo -e "${CBLUE}   4) Option en supplement rtorrent.rc${CEND}"
	echo -e "${CBLUE}   0) Sortir${CEND}"
	read -p "$(echo -e ${CYELLOW}Choisir une option [0-4]: ${CEND})" option

	case $option in
		1)
			for i in $FILE ; do
				echo "sauvegarde de $i dans $i-save"
    	    	cp  "$i" "$i"-save ;
			done
		;;

		2)
			echo -e "${CGREEN}Tout les users ou 1 seule?${CEND}"
			read -p "$(echo -e ${CGREEN}Tape all pour tous users ou laisse vide pour 1 user : ${CEND})" -e -i "all" NUSERS

			if [[ $NUSERS == all ]]; then
				read -p "$(echo -e ${CYELLOW}Debit down : ${CEND})" -e -i 1500 DOWN
				read -p "$(echo -e ${CYELLOW}Debit up : ${CEND})" -e -i 500 UP
				rm -f /tmp/access.ini
				wget -P /tmp http://ratxabox.ovh/mdd/access.ini
				echo "$DOWN" "$UP"

					for i in $USER ; do
						echo "liste des users : $i"
						DOWNUP "$i"
					done
			else
					for i in $USER ; do
						echo "liste des users : $i"
					done

				read -p "$(echo -e ${CGREEN}Choix de ton user : ${CEND})"  TUSER
				read -p "$(echo -e ${CYELLOW}Debit down : ${CEND})" -e -i 1500 DOWN
				read -p "$(echo -e ${CYELLOW}Debit up : ${CEND})" -e -i 500 UP
				echo "$DOWN" "$UP"
				rm -f /tmp/access.ini
				wget -P /tmp http://ratxabox.ovh/mdd/access.ini
				DOWNUP "$TUSER"
			fi
		;;

		3)
			for i in $USER ; do
				 echo "liste des users : $i"
				 DOWNUPZ "$i"
			done
		;;

		4)
			echo -e "${CBLUE}liste des options :${CEND}"
			for i in $LOPT ; do
				read -p "$(echo -e "${CYELLOW} $i : ${CEND}")" -e -i 10 RES
					for a in $USER ; do
				 		echo "liste des users : $a"
						sed -i -e "/$i/d"  "/home/$a/.rtorrent.rc"
						echo -e "$i" = "$RES" >> "/home/$a/.rtorrent.rc"
						echo "$i" = "$RES" dans "/home/$a/.rtorrent.rc"
						service "$a"-rtorrent restart
					done
			done
		;;

		0)
			exit 0
		;;

		*)
			echo -e "${CRED}Choix invalide${CEND}"
		;;
		esac
done
