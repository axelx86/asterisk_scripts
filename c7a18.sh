#!/bin/bash

############### update system packages ###############
yum update -y

#--------------------------------------------------------------------------------------------------------------------------------------

############### dialog install ###############
yum install -y -q dialog

#--------------------------------------------------------------------------------------------------------------------------------------

############### disable selinux and ynstall required packages ###############
setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
yum -y install epel-release make gcc gcc-c++ kernel-headers-`uname -r` kernel-devel-`uname -r` ncurses-devel newt-devel
yum -y libtiff-devel libxml2-devel sqlite-devel glibc-headers dmidecode ncurses-devel wget openssl-devel kernel-devel sqlite-devel
yum -y libuuid-devel gtk2-devel jansson-devel binutils-devel libedit libedit-devel svn mc git
yum -y groupinstall core base "Development Tools"
#--------------------------------------------------------------------------------------------------------------------------------------

############### Create asterisk source directory and download source codes ###############
mkdir /usr/src/asterisk
cd /usr/src/asterisk
wget http://downloads.asterisk.org/pub/telephony/libpri/libpri-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-18.7.1.tar.gz
wget http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-18.7.1.tar.gz
git clone https://github.com/akheron/jansson.git
git clone https://github.com/pjsip/pjproject.git

#--------------------------------------------------------------------------------------------------------------------------------------
############### build jansson from source ###############
cd /usr/src/asterisk/jansson/
sudo autoreconf  -i 
sudo ./configure --prefix=/usr/ 
sudo make 
sudo make install

#--------------------------------------------------------------------------------------------------------------------------------------

############### build pjproject from source ###############
cd /usr/src/asterisk/pjproject/
./configure CFLAGS="-DNDEBUG -DPJ_HAS_IPV6=1" --prefix=/usr --libdir=/usr/lib64 --enable-shared --disable-video --disable-sound --disable-opencore-amr # ???
make dep
make 
make install
ldconfig
#--------------------------------------------------------------------------------------------------------------------------------------

############### build dahdi from source ###############
#tar -xvf dahdi-linux-3.1.0.tar.gz
#--------------------------------------------------------------------------------------------------------------------------------------

############### build libpri from source ###############
tar -xvf libpri-current.tar.gz
#cd ./libpri-1.6.0/
cd ./libpri-*
make clean
make
make install
#--------------------------------------------------------------------------------------------------------------------------------------

############### build asterisk-18.7.1 from source ###############
tar -xvf asterisk-18.7.1.tar.gz
/usr/src/asterisk/asterisk-18.7.1/contrib/scripts/get_mp3_source.sh
/usr/src/asterisk/asterisk-18.7.1/contrib/scripts/install_prereq install
#cd /usr/src/asterisk/asterisk-18.7.1
cd /usr/src/asterisk/asterisk-*
./configure --libdir=/usr/lib64 --with-jansson-bundled --with-pri --with-iconv --with-libcurl --with-speex --with-mysqlclient
make menuselect # ???
make
make install

