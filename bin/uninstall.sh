#!/usr/bin/env bash

# Uninstall Wordpress under nginx on Debian box made with the install.sh script

# Variables, change them accoriding to your needs
NGINX_AVAILABLE_VHOSTS='/etc/nginx/sites-available'
NGINX_ENABLED_VHOSTS='/etc/nginx/sites-enabled'
WEB_DIR='/var/www'
WEB_USER='www-data'
phpVersion=7.3

red=`tput setaf 1`
green=`tput setaf 2`
nocolor=`tput sgr0`

# Functions

remove_nginx() {
   apt -y purge nginx
   echo "${green}Nginx is purged!${nocolor}"
}

remove_nginx_config() {
   rm -f /etc/nginx/sites-enabled/$1
   rm -f /etc/nginx/sites-available/$1
}

remove_php() {
    echo "${green}Removing PHP ...${nocolor}" 
    apt -y purge php$phpVersion
    apt -y purge php$phpVersion-cli php$phpVersion-fpm php$phpVersion-json php$phpVersion-pdo php$phpVersion-mysql php$phpVersion-zip php$phpVersion-gd  php$phpVersion-mbstring php$phpVersion-curl php$phpVersion-xml php$phpVersion-bcmath php$phpVersion-json
    echo "${green}PHP Removed ...${nocolor}" 
}
remove_mysql() {
    echo "${green}Removing MySQL ...${nocolor}" 
    apt -y purge mariadb-server
    apt -y purge mariadb-client
    echo "${green}MySQL Removed ...${nocolor}" 
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

# Uninstall php
if [ "$2" == "purge" ]; then
    if ! which php > /dev/null 2>&1; then
        echo "${red}PHP not installed, ok ...${nocolor}"
    else 
        echo "${green}PHP present!${nocolor}"
        remove_php
    fi
fi

# Uninstall mysql
if [ "$2" == "purge" ]; then
    if ! which mysql > /dev/null 2>&1; then
        echo "${red}MySQL not installed, ok ...${nocolor}"
    else 
        echo "${green}MySQL present!${nocolor}"
        remove_mysql
    fi
fi



echo "${green}Done. Removed $1${nocolor}"
