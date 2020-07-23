#!/usr/bin/env bash

# Uninstall Wordpress under nginx on Debian box made with the install.sh script

# Variables, change them accoriding to your needs
NGINX_AVAILABLE_VHOSTS='/etc/nginx/sites-available'
NGINX_ENABLED_VHOSTS='/etc/nginx/sites-enabled'
WEB_DIR='/var/www'
WEB_USER='www-data'

red=`tput setaf 1`
green=`tput setaf 2`
nocolor=`tput sgr0`

# Functions

remove_nginx() {
   apt purge nginx
   echo "${green}Nginx is purged!${nocolor}"
}

remove_nginx_config() {
   rm -f /etc/nginx/sites-enabled/$1
   rm -f /etc/nginx/sites-available/$1
}

# Must be root
if [ $(id -u) -ne 0 ]
  then echo "${red}You must be root to install Wordpress.${nocolor}"
  exit
fi

# Must have a domainName argument
if [ ! $1 ]; then
    echo "${red}You must have a domain argument${nocolor}"
    echo "Usage: $(basename $0) domainName"
    exit
fi

if [ -e $NGINX_AVAILABLE_VHOSTS/$1 ]; then
    echo "${green}Domain present! Removing!!!${nocolor}"
    remove_nginx_config $1
    echo "${green}Removing logs.${nocolor}"
    rm -Rf $WEB_DIR/logs/$1
    echo "${green}Removing web directory. ${nocolor}"
    rm -Rf $WEB_DIR/$1
else 
    echo "${green}Domain $1 not found. ${nocolor}"
    exit
fi

# Uninstall nginx
if [ "$2" == "purge" ]; then
    if ! which nginx > /dev/null 2>&1; then
        echo "${red}Nginx not installed, ok ...${nocolor}"
    else 
        echo "${green}Nginx present!${nocolor}"
        remove_nginx
    fi
fi

echo "${green}Done. Removed $1${nocolor}"
