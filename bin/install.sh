#!/usr/bin/env bash

# Install Wordpress under nginx on Debian box

# Variables, change them accoriding to your needs
NGINX_AVAILABLE_VHOSTS='/etc/nginx/sites-available'
NGINX_ENABLED_VHOSTS='/etc/nginx/sites-enabled'
WEB_DIR='/var/www'
WEB_USER='www-data'
USER='www-data'
domain=$1
phpVersion=7.3

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
# Upstream to abstract backend connection(s) for php
upstream php {
        server unix:/tmp/php-cgi.socket;
        server 127.0.0.1:9000;
}

server {
        ## Your website name goes here.
        server_name $1;
        ## Your only path reference.
        root $WEB_DIR/$1;
        ## This should be in your http block and if it is, it's not needed here.
        index index.php;
        access_log $WEB_DIR/logs/$1/access.log;
        error_log  $WEB_DIR/logs/$1/error.log;
        location = /favicon.ico {
                log_not_found off;
                access_log off;
        }

        location = /robots.txt {
                allow all;
                log_not_found off;
                access_log off;
        }

        location / {
                # This is cool because no php is touched for static content.
                # include the "?$args" part so non-default permalinks doesn't break when using query string
                try_files $uri $uri/ /index.php?$args;
        }

        location ~ \.php$ {
                #NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
                include fastcgi_params;
                fastcgi_intercept_errors on;
                fastcgi_pass php;
                #The following parameter can be also included in fastcgi_params file
                fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }

        location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
                expires max;
                log_not_found off;
        }
}

EOF
}

# Function to check if the PHP version is valid
checkPHPVersion() {

    # The current PHP Version of the machine
    PHPVersion=$(php -v|grep --only-matching --perl-regexp "5\.\\d+\.\\d+");
    # Truncate the string abit so we can do a binary comparison
    currentVersion=${PHPVersion::0-2};
    # The version to validate against
    minimumRequiredVersion=$1;
    # If the version match
    if [ $(echo " $currentVersion >= $minimumRequiredVersion" | bc) -eq 1 ]; then
        # Notify that the versions are matching
        echo "${green}PHP Version is valid ...${nocolor}";
    else
        # Else notify that the version are not matching
        echo "${red}PHP Version NOT valid for ${currentVersion} ...${nocolor}";
        # Return fail
        return 1
    fi

}

install_php() {
    echo "${green}Installing PHP ...${nocolor}"   
    apt update
    apt upgrade -y
    apt -y install lsb-release apt-transport-https ca-certificates 
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php$phpVersion.list
    apt update
    apt -y install php$phpVersion
    apt install php$phpVersion-cli php$phpVersion-fpm php$phpVersion-json php$phpVersion-pdo php$phpVersion-mysql php$phpVersion-zip php$phpVersion-gd  php$phpVersion-mbstring php$phpVersion-curl php$phpVersion-xml php$phpVersion-bcmath php$phpVersion-json
    echo "${green}Done. Installed PHP ...${nocolor}"   
}

#################################################################

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

# Check and Install PHP
# Apache will not launch as nginx is here
if [ $(checkPHPVersion $phpVersion) -eq 0 ]; then
    echo "${green}PHP Version OK...${nocolor}"
else
    echo "${red}PHP Version NOT OK...${nocolor}"
    install_php
fi


if [ -e $NGINX_AVAILABLE_VHOSTS/$1 ]; then
    echo "${red}Domain present! not installing!!!${nocolor}"
    exit
else 
    echo "${green}Installing domain $1 ${nocolor}"
    create_nginx_config $1

    # Creating {public,log} directories
    mkdir -p $WEB_DIR/logs/$1

    wget -O $WEB_DIR/wordpress.tgz https://wordpress.org/latest.tar.gz
    cd $WEB_DIR
    tar -zxf wordpress.tgz
    sleep 2
    cp -r $WEB_DIR/wordpress $WEB_DIR/$1
    rm $WEB_DIR/wordpress.tgz
    rm -Rf $WEB_DIR/wordpress
    echo "${green}Succesfully copied contents to web dir${nocolor}"

    # Changing permissions
    chown -R $USER:$WEB_USER $WEB_DIR/$1
    #Enable site by creating symbolic link
    ln -s $NGINX_AVAILABLE_VHOSTS/$1 $NGINX_ENABLED_VHOSTS/$1
    echo "${green}Done. Installed $1 in nginx${nocolor}"
fi

# Install Mysql

# Define databases
#CREATE DATABASEANAME
dbname="$(openssl rand -base64 5 | tr -d "=+/" | cut -c1-25)$2"
echo "successfully created database name"
# CREATE DATABASE USERNAME

MAINDB="$(openssl rand -base64 8 | tr -d "=+/" | cut -c1-25)$2"
echo "successfully created database username"
# CREATE DATABASE USERNAME PASSWORD
PASSWDDB="$(openssl rand -base64 29 | tr -d "=+/" | cut -c1-25)"
echo "successfully created database username password"
