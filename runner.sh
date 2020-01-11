#!/bin/bash

if [  !  -f   $(pwd)/_ips  ] ; then echo "File  $(pwd)/_ips not found"; exit; fi
if [  !  -f   $(pwd)/_ports  ] ; then echo "File  $(pwd)/_ports not found"; exit; fi
if [  !  -f   $(pwd)/_pass  ] ; then echo "File  $(pwd)/_pass not found"; exit; fi
if [  !  -f   $(pwd)/_users  ] ; then echo "File  $(pwd)/_users not found"; exit; fi

IP_DATA=$(< _ips)
PORTS_DATA=$(< _ports)
PASSWORDS_DATA=$(< _pass)
USER_NAMES=$(< _users)
cnt=0

if  ! [ -x "$(command -v sshpass )" ]; then
	echo "[sshpass] Installing requirements.."
	if [ "$EUID" -ne 0 ] ; then
		if   [ -x "$(command -v  sudo )" ]; then
			sudo apt install  -y sshpass
		else
			echo "Need superuser privileges to install requirements , run again script as root"
			exit
			fi
	else
		apt install  -y sshpass
	fi
fi


function readData() {
 IPS=( $( for i in $IP_DATA ; do if [ ! ${i:0:1} = '#'  ] ; then  echo $i  ;	fi ;	 done ) 	)
 PASS=( $( for i in $PASSWORDS_DATA ; do if [ ! ${i:0:1} = '#'  ] ; then  echo $i  ;	fi ; done ) )
 PORTS=( $( for i in $PORTS_DATA ; do if [ ! ${i:0:1} = '#'  ] ; then  echo $i  ;	fi ; done ) )
 USERS=( $( for i in $USER_NAMES ; do if [ ! ${i:0:1} = '#'  ] ; then  echo $i  ;	fi ; done ) )
# 	echo ${#IPS[@]} ${#PASS[@]} ${#PORTS[@]}
 	if [  ! ${#IPS[@]} =  ${#PORTS[@]}  ] || [ ! ${#USERS[@]} = ${#PASS[@]} ] ||  [ ! ${#USERS[@]} = ${#IPS[@]} ]  ; then
 		echo "Every Ip has to match a pass , a port and username .Abort"
 		exit
 	fi
}
readData  #	l o a d 	d a t a

function main(){
 for i in ${IPS[@]} ; do
echo "Connecting to " ${USERS[$cnt]}"@"$i "	over "${PORTS[$cnt]}" using	"${PASS[$cnt]} " as password."
sshpass  -p ${PASS[$cnt]} ssh -t -q  ${USERS[$cnt]}@$i -p  ${PORTS[$cnt]} 	' 	
	# enter here remote commands you want to be executed ;
	echo "hello";
	 '
 
let "cnt=cnt+1"
done 
}


printf "\n"

main