# DynDns - Hostinet IP Dinámica

## 1. Instalación

Es necesario dar permisos de ejecución al archivo: `chmod +x ./ddns.sh`

## 2. Funcionamiento del script

### IP Automática

De esta forma, se actualizará la ip para www.midominio.com

```
./ddns.sh -d HOSTINET_DOMAIN -p HOSTINET_PASSWORD -h HOST
./ddns.sh -d midominio.com -p xxxxxxxxx -h www
```

### Fijar IP

Igual que antes, pero indicando la ip que se quiere asignar, tanto en www como mail.  

```
./ddns.sh -d HOSTINET_DOMAIN -p HOSTINET_PASSWORD -h HOST -i IP
./ddns.sh -d midominio.com -p xxxxxxxxx -h www,mail -i IP
```

### Usando el fichero de configuración.

Es recomendable usar el fichero de configuración para guardar las claves en vez de indicarlas por línea de comandos.

```
./ddns.sh -c FILECONF
```

Las demás opciones se pueden seguir usando igual

```
./ddns.sh -c FILECONF -d midominio.com -h www,mail
./ddns.sh -c FILECONF -d midominio.com -h www,mail -i 172.12.1.23
```

El fichero de configuración por defecto es el siguiente:

```
ddns.conf
```
Copia el archivo en la siguiente ruta completando los datos necesarios
```
/etc/hostinet/ddns.conf
```
Si tienes activado el API en tu ficha de cliente puedes usar el APPKEY y APPSECRET

```
HOSTINET_APPKEY="APIKEY"
HOSTINET_APPSECRET="APISECRET"
```

## CRON

Para lanzar el script de forma automática, y cada vez que se actualize la dirección IP de un equipo, se debe añadir la siguiente linea en el cron (fichero `/etc/crontab`)  

```
*/15 * * * * user test -x /etc/hostinet/ddns.sh && /etc/hostinet/ddns.sh -c /etc/hostinet/ddns.conf
```
