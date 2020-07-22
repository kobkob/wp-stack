#!/usr/bin/env bash

# Install Wordpress under nginx on Debian box

red=`tput setaf 1`
green=`tput setaf 2`
nocolor=`tput sgr0`

# Functions
install_nginx() {
    apt-get install -y nginx
}

# Must be root
if [ $(id -u) -ne 0 ]
  then echo "${red}You must be root to install Wordpress.${nocolor}"
  exit
fi


if ! which nginx > /dev/null 2>&1; then
    echo "${red}Nginx not installed ...${nocolor}"
    echo "${green}Installing Nginx ...${nocolor}"
    install_nginx()
else 
    echo "${green}Nginx present!${nocolor}"
fi
