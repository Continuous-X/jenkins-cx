#! /bin/sh

echo "
>> update operating system
"
apt-get update -y
apt-get upgrade -y

echo "
>> install packages
"
apt-get install -y git unzip git-lfs gpg

echo "
>> clean
"
apt-get autoclean -y
apt-get autoremove -y
