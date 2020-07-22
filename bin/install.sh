#!/usr/bin/env bash

# Install Wordpress under nginx on Debian box

red=`tput setaf 1`
green=`tput setaf 2`
nocolor=`tput sgr0`

# Functions
#ok() { echo -e '\e[32m'$1'\e[m'; } # Green
install_nginx() {
    apt install nginx
}

# Must be root
if [ $(id -u) -ne 0 ]
  then echo "${red}You must be root to install Wordpress.${nocolor}"
  exit
fi


if ! which nginx > /dev/null 2>&1; then
    echo "${red}Nginx not installed ...${nocolor}"
else 
    echo "${green}Nginx present!${nocolor}"
fi
