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

# Functions
install_nginx() {
    apt-get install -y nginx
}
# Create nginx config file
create_nginx_config() {
    cat > $NGINX_AVAILABLE_VHOSTS/$1 <<EOF # Start server block info
# www to non-www
server {
    listen 80;
    # If user goes to www direct them to non www
    server_name *.$domain;
    return 301 $NGINX_SCHEME://$1$NGINX_REQUEST_URI;
}
server {
    # Just the server name
    listen 80;
    server_name $1.$domain;
    root        $WEB_DIR/$1/;
   index index.php index.html index.htm;
    # Logs
    access_log $WEB_DIR/logs/$1/access.log;
    error_log  $WEB_DIR/logs/$1/error.log;
location / {
 proxy_read_timeout 150;
 try_files $uri $uri/ /index.php?$args;
}
    location ~ \.php$ { 
include snippets/fastcgi-php.conf; 
fastcgi_pass unix:/var/run/php/php7.1-fpm.sock; # You might want to change the PHP version to 7.3
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name; 
include fastcgi_params;
fastcgi_read_timeout 600; 
proxy_connect_timeout 600; 
proxy_send_timeout 600; 
proxy_read_timeout 600;
send_timeout 600;
client_max_body_size 50M; 
}
  }
EOF
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


# Test and install nginx if not installed
if ! which nginx > /dev/null 2>&1; then
    echo "${red}Nginx not installed ...${nocolor}"
    echo "${green}Installing Nginx ...${nocolor}"
    install_nginx
else 
    echo "${green}Nginx present!${nocolor}"
fi

if [ -e $NGINX_AVAILABLE_VHOSTS/$1 ]; then
    echo "${red}Domain present! not installing!!!${nocolor}"
    exit
else 
    echo "${green}Installing domain $1 ${nocolor}"
    create_nginx_config
fi
