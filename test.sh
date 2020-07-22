#!/usr/bin/env bash

# Install Wordpress under nginx on Debian box

# Variables, change them accoriding to your needs
NGINX_AVAILABLE_VHOSTS='/etc/nginx/sites-available'
NGINX_ENABLED_VHOSTS='/etc/nginx/sites-enabled'
WEB_DIR='/var/www/wordpress'
WEB_USER='www-data'
USER='www-data'
zone='America\/New_York'		# Time zone that will be auto selected when running setup make sure to inlcude the \ I recommend to leave this as is and change it during the setup.
					# you can find list of zones supported by vtiger at: https://discussions.vtiger.com/discussion/190812/time-zone-setting-list-is-empty
currency='USA, Dollars'				# Currency that will be auto selected when running setup Ex. Jamaica, Dollars | Isle of Man, Pounds | Iran, Rials | USA, Dollars | Netherlands Antilles, Guilders etc. If unsure, leave it as is, and change during setup.
date='dd-mm-yyyy'			# Date format that will be auto selected when running setup
date2='"dd-mm-yyyy"'			# Date format with  make sure to fill this one is as well must be the same as date
vtigeradmin='password'			# Password for the default admin user
rootpasswd='MYSQLROOTPASS'		# root password mysql used for making database
domain='example.com'

# Do NOT edit the following variables!!!
NGINX_SCHEME='$scheme'
NGINX_REQUEST_URI='$request_uri'
uri='$uri'
args='$args'
document_root='$document_root'
fastcgi_script_name='$fastcgi_script_name'
defaultzone='America\/Los_Angeles'
defaultcurrency='USA, Dollars'
defaultdate='"mm-dd-yyyy"'

red=`tput setaf 1`
green=`tput setaf 2`
nocolor=`tput sgr0`

if [ ! $1 ]; then
    echo "${red}You must have a domain argument${nocolor}"
    echo "Usage: $(basename $0) domainName"
    exit
fi

if [ -e $NGINX_AVAILABLE_VHOSTS/$1 ]; then
    echo "${red}Domain present! not installing!!!${nocolor}"
    exit
else 
    echo "${green}Installing domain $1 ${nocolor}"
fi


