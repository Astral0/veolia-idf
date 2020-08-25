#!/bin/bash

set -e

VEOLIA_LOGIN=$1
VEOLIA_PASSWORD=$2
VEOLIA_CONTRACT=$3

echo " >>>> Installation de Veolia-idf <<<<"

# Get current directory
set_root() {
    local this=`readlink -n -f $1`
    root=`dirname $this`
}
set_root $0
cd ${root}


# Parameters
CONF=${root}/config.json


# Prerequis
apt update
apt -y upgrade
apt install -y whiptail

# Setup login and password
if [ -z ${VEOLIA_LOGIN} ] ; then
    VEOLIA_LOGIN=$(whiptail --title "Input" --inputbox "VEOLIA Account Email" 10 60 3>&1 1>&2 2>&3)
    exitstatus=$? && if [ ! $exitstatus = 0 ]; then VEOLIA_LOGIN= ; fi
fi

if [ -z ${VEOLIA_PASSWORD} ] ; then
    VEOLIA_PASSWORD=$(whiptail --title "Input" --inputbox "VEOLIA Account Password" 10 60 3>&1 1>&2 2>&3)
    exitstatus=$? && if [ ! $exitstatus = 0 ]; then VEOLIA_PASSWORD= ; fi
fi

if [ -z ${VEOLIA_CONTRACT} ] ; then
    VEOLIA_CONTRACT=$(whiptail --title "Input" --inputbox "VEOLIA Contract Number" 10 60 3>&1 1>&2 2>&3)
    exitstatus=$? && if [ ! $exitstatus = 0 ]; then VEOLIA_CONTRACT= ; fi
fi

if [ -z $VEOLIA_LOGIN ] || [ -z $VEOLIA_PASSWORD ] || [ -z $VEOLIA_CONTRACT ]; then
    whiptail --title "VEOLIA Account informations missing..." --msgbox "Please add your credentials manually in ${CFG}" 10 60
fi


# Locales
locale-gen fr_FR
locale-gen fr_FR.UTF-8

# Prerequis
apt install -y software-properties-common gnupg wget hostname git nano sudo
apt install -y python3 python3-pip 


# Chosse one :
apt install -y xvfb xserver-xephyr
#apt install -y vnc4server blackbox
apt install -y rxvt iceweasel firefox-esr



# Install Gecko driver
cd ${root}
wget https://github.com/mozilla/geckodriver/releases/download/v0.26.0/geckodriver-v0.26.0-linux64.tar.gz
tar xzfz geckodriver-v0.26.0-linux64.tar.gz
mv geckodriver /usr/local/bin
rm -f geckodriver
ln -s /usr/local/bin/geckodriver geckodriver
rm geckodriver-v0.26.0-linux64.tar.gz

chmod ugo+x veolia-idf-domoticz.py


# Adjust config file
cd ${HOME_VEOLIA}
cp -ax config.json.exemple config.json
#
if [ ! -z $VEOLIA_LOGIN ]; then
    sed -i "s/^.*\"veolia_login\":.*/    \"veolia_login\":\"$VEOLIA_LOGIN\",/g" $CONF
fi
#
if [ ! -z $VEOLIA_PASSWORD ]; then
    sed -i "s/^.*\"veolia_password\":.*/    \"veolia_password\":\"$VEOLIA_PASSWORD\",/g" $CONF
fi
#
if [ ! -z $VEOLIA_CONTRACT ]; then
    sed -i "s/^.*\"veolia_contract\":.*/    \"veolia_contract\":\"$VEOLIA_CONTRACT\",/g" $CONF
fi


# Install prerequisites
pip3 install --upgrade pip
pip3 install --no-cache-dir -r requirements.txt -t ${root}/lib
#
chmod 755 ${root}/bin/run.sh

echo ">>>> Installation finished ! launch : ${root}/bin/run.sh "



