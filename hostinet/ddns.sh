#!/bin/bash

##############################################
#	Hostinet - IP Dinámica
# Fichero de configuración por defecto
# @author: Hostinet SLU
# @email: desarrollo@hostinet.com
##############################################

DEFAULTCONFIG=/etc/hostinet/ddns.conf
APIURLDDNS="https://www.hostinet.com/central/utilities/ddns/"
APIURLDYNDNS="https://www.hostinet.com/api/domain/dyndns/"
APIVERSION="1.0"
WGET=$(which wget)
CURL=$(which curl)
ECHO=$(which echo)
WGETOPT="-q --no-check-certificate -O- --user-agent=wgetddns/${APIVERSION} --post-data"
CURLOPT="-X POST -A wgetddns/${APIVERSION} --data"

function CheckCurlOrWget()
{
	if [[ ! -x "${WGET}" && ! -x "${CURL}" ]]; then
		Usage "wget/curl command not found!!"
	fi
}

function CallAPI
{
  HOST=$1
  if [[ -n "${HOSTINET_APPKEY}" && -n "${HOSTINET_APPSECRET}" ]]; then
    APIURL=$APIURLDYNDNS
    DATAURL="domain=${HOSTINET_DOMAIN}"
    DATAURL+="&host=${HOST}"
    DATAURL+="&appkey=${HOSTINET_APPKEY}&appsecret=${HOSTINET_APPSECRET}"
  elif [[ -n "${HOSTINET_PASSWORD}" ]]; then
    APIURL=$APIURLDDNS
    DATAURL="dom=${HOSTINET_DOMAIN}"
    DATAURL+="&host=${HOST}"
    DATAURL+="&pw=${HOSTINET_PASSWORD}"
  else
    Usage "Missing KeyPairs or Password"
  fi

  if [ -n "${HOSTINET_IP}" ]; then
    DATAURL+="&ip=${HOSTINET_IP}"
  fi
  if [ -n "${CURL}" ]; then
		$CURL $CURLOPT "${DATAURL}" "$APIURL"
  elif [ -n "${WGET}" ]; then
		$WGET $WGETOPT "${DATAURL}" "$APIURL" > /dev/null 2>&1
  fi
}

function Usage()
{
	echo ""
	echo "Hostinet - IP Dinámica/Dynamic IP"
	if [ -n "$1" ]; then
		echo " ERROR: $1"
		echo ""
	fi

	echo "Usage: $0 -d <DOMAIN> -p <PASSWORD> -h <HOST> [-i <IP>]"
	echo "Usage: $0 -c <CONFIGFILE> [-i <IP>] [-h <HOST>] [-p <PASSWORD>] [-d <DOMAIN>]"
	echo ""
	echo "Nota:"
	echo " * Archivo de configuración por defecto $DEFAULTCONFIG";
	echo " * Si no se especifica una ip, esta se obtiene automáticamente"
	echo ""
	exit 1;
}

HOSTINET_CONFIG=$DEFAULTCONFIG
HOSTINET_DOMAIN=""
HOSTINET_APPKEY=""
HOSTINET_APPSECRET=""
HOSTINET_PASSWORD=""
HOSTINET_HOST=""
HOSTINET_IP=""

CheckCurlOrWget;

while getopts ":d:p:h:c:i:" opt; do
	case $opt in
		c)
			if [ ! -f "$OPTARG" ]; then
				Usage "Invalid file config: $OPTARG"
			fi
			HOSTINET_CONFIG=$OPTARG
			;;
		d)
			mydomain=$OPTARG
			;;
		p)
			mypass=$OPTARG
			;;
		h)
			myhost=$OPTARG;
			;;
		i)
			myip=$OPTARG;
			;;
		\?)
			Usage "Invalid argument!";
			;;
	esac
done
shift $((OPTIND -1))

if [ -f "$HOSTINET_CONFIG" ]; then
	. $HOSTINET_CONFIG
fi
if [ "$mydomain" ]; then
	HOSTINET_DOMAIN=$mydomain
fi
if [ "$mypass" ]; then
	HOSTINET_PASSWORD=$mypass
fi
if [ "$myhost" ]; then
	HOSTINET_HOST=$myhost
fi
if [ "$myip" ]; then
	HOSTINET_IP=$myip
fi

if [[ "$HOSTINET_DOMAIN" = "" || "$HOSTINET_HOST" = "" ]]; then
	Usage "Missing data"
fi

$ECHO "$HOSTINET_HOST" | awk -F"," '{
  split($0, WORDS, ",");
  for (WORD in WORDS) {
    print($WORD);
  };
}' | while read -r HOST; do
  CallAPI "$HOST"
done

exit 0;
