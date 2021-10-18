#!/bin/bash

# disable selinux
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
sudo setenforce 0

# updates & installs
 yum update -y && yum groupinstall core base "Development Tools" -y && yum install mc -y
 
# install dev tools
#yum groupinstall core base "Development Tools" -y

# install mc
#yum install mc -y

# install date/time&ntp
# timedatectl set-timezone Europe/Moscow
# yum install ntp -y
# systemctl start ntpd.service
# systemctl enable ntpd.service

# install dialog
yum install -y -q dialog

# add mariadb repo
echo "# MariaDB 10.5 CentOS repository list - created 2020-12-09 10:18 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.5/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
" > /etc/yum.repos.d/Mariadb.repo

# install & configure mariadb
yum install MariaDB-server MariaDB-client MariaDB-shared mariadb-devel -y
systemctl start mariadb
systemctl enable mariadb

# install dependences
yum install kernel-devel kernel-headers -y
yum install kernel-headers-`uname -r` kernel-devel-`uname -r` newt-devel glibc-headers -y
yum install e2fsprogs-devel keyutils-libs-devel krb5-devel libogg -y
yum install libselinux-devel libsepol-devel libxml2-devel libtiff-devel gmp php-pear -y
yum install php php-gd php-mysql php-pdo php-mbstring ncurses-devel -y
yum install audiofile-devel libogg-devel openssl-devel zlib-devel -y
yum install perl-DateManip sox git wget net-tools psmisc -y
yum install gcc gcc-c++ make gnutls-devel -y
yum install subversion doxygen -y
yum install texinfo curl-devel net-snmp-devel neon-devel -y
yum install uuid-devel libuuid-devel sqlite-devel sqlite -y
yum install speex-devel gsm-devel libtool libtool-ltdl libtool-ltdl-devel -y
yum install libsrtp libsrtp-devel -y
yum install unixODBC unixODBC-devel -y
yum install mysql-connector-odbc -y
yum install sendmail sendmail-cf ibtiff-devel gtk2-devel cronie cronie-anacron -y
yum install tftp-server python-devel linx crontabs jansson-devel lame curl corosync corosync-devel -y
##### backup 2 #####

######################################################################################
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
yum install xmlstarlet -y
######################################################################################
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
yum-config-manager --enable remi-php56
yum install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo -y
######################################################################################
# mysql_secure_installation
# Если вы задали пароль root пользователя mysql, позднее, при установке FreePBX выполните скрипт ./install в интерактивном режиме без ключа «-n».
# В ходе выполнения установки вам будет предложено ввести пароль пользователя root в mysql.
# Введите ранее заданный пароль.
######################################################################################

# editing apache
sed -i 's/upload_max_filesize = 20M/upload_max_filesize = 120M/g' /etc/php.ini
#sed -i s/;date.timezone =/date.timezone = "Europe/Moscow"/g /etc/php.ini
sed -i 's/^\(User\|Group\).*/\1 asterisk/' /etc/httpd/conf/httpd.conf
sed -i 's/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
systemctl restart httpd.service

# prepare to install ASTERISK
 # create directory asterisk source
mkdir /usr/src/asterisk
 # enter the directory
cd /usr/src/asterisk 
######################################################################################
# choose your version
echo "Выберите желаемую для установки версию Asterisk:"
echo "Select the version of Asterisk you want to install:"
read aversion
echo "Выберите желаемую для установки версию FreePBX:"
echo "Select the version of fversion you want to install:"
read fversion
# download components
wget https://netix.dl.sourceforge.net/project/srtp/srtp/1.4.4/srtp-1.4.4.tgz
wget https://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-current.tar.gz
wget https://downloads.asterisk.org/pub/telephony/libpri/libpri-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-$aversion-current.tar.gz
#wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-16-current.tar.gz
wget http://mirror.freepbx.org/modules/packages/freepbx/freepbx-$fversion.0-latest.tgz
#wget http://mirror.freepbx.org/modules/packages/freepbx/freepbx-14.0-latest.tgz
#wget http://mirror.freepbx.org/modules/packages/freepbx/freepbx-15.0-latest.tgz
######################################################################################

# nodejs install
curl -sL https://rpm.nodesource.com/setup_10.x | bash -
yum clean all && sudo yum makecache fast
yum install gcc-c++ make nodejs -y
#node -v
######################################################################################

# srtp install
Установка SRTP (если необходимо использовать)
tar zxvf srtp-1.4.4.tgz
Далее необходимо заменить в файле /usr/src/srtp/test/rtpw_test.sh строчку RTPW=rtpw на строчку RTPW=./rtpw
cd srtp
autoconf
./configure CFLAGC=-fPIC --prefix=/usr
make
make runtest
make install

# jansson
cd /usr/src/
git clone https://github.com/akheron/jansson.git
cd jansson
autoreconf -i
./configure --prefix=/usr/
make && make install

# pjsip install
cd /usr/src/
#export VER="2.8"
#export VER="2.10"
#wget http://www.pjsip.org/release/${VER}/pjproject-${VER}.tar.bz2
wget https://github.com/pjsip/pjproject/archive/2.10.tar.gz
tar zxvf pjproject-${VER}.tar.bz2
cd pjproject-${VER}
./configure CFLAGS="-DNDEBUG -DPJ_HAS_IPV6=1" --prefix=/usr/ --libdir=/usr/lib64/ --enable-shared --disable-video --disable-sound --disable-opencore-amr
make dep && make && make install && ldconfig

##### backup 3 #####

# dahdi install
#tar zxvf dahdi-linux-complete-current.tar.gz
#cd /usr/src/asterisk/dahdi*
#make all
#make install
#make install-config

# libpri install
#tar zxvf libpri-current.tar.gz
#cd /usr/src/asterisk/libpri*
#make clean
#make
#make install

##### backup 3 #####

# asterisk install
#tar zxvf asterisk-*
tar zxvf asterisk-$version-current.tar.gz
cd /usr/src/asterisk/asterisk*
contrib/scripts/install_prereq install
contrib/scripts/get_mp3_source.sh
./configure --with-pjproject-bundled --with-jansson-bundled --with-crypto --with-ssl=ssl --with-srtp --libdir=/usr/lib64
#./configure --prefix=/usr --exec-prefix=/usr --with-crypto --with-dahdi
# --with-iconv -with-libcurl --with-gmime --with-iksemel --with-mysqlclient
# --disable-xmldoc --with-pri --with-spandsp --with-ldap --with-libcurl --with-popt
# --with-resample --with-speex --with-unixodbc --with-jansson-bundled
make menuselect
make && make install && make config && make samples && ldconfig

##### backup 4 #####

#sed -i 's/ASTARGS=""/ASTARGS="-U asterisk"/g' /usr/sbin/safe_asterisk
#useradd -m asterisk
#chown asterisk.asterisk /var/run/asterisk
#chown -R asterisk.asterisk /etc/asterisk
#chown -R asterisk.asterisk /var/{lib,log,spool}/asterisk
#chown -R asterisk.asterisk /usr/lib/asterisk



echo '[directories](!)
astetcdir => /etc/asterisk
astmoddir => /usr/lib64/asterisk/modules
astvarlibdir => /var/lib/asterisk
astdbdir => /var/lib/asterisk
astkeydir => /var/lib/asterisk
astdatadir => /var/lib/asterisk
astagidir => /var/lib/asterisk/agi-bin
astspooldir => /var/spool/asterisk
astrundir => /var/run/asterisk
astlogdir => /var/log/asterisk
astsbindir => /usr/sbin

[options]
runuser = asterisk
rungroup = asterisk
defaultlanguage = ru
documentation_language = en_US

[files]
astctlpermissions = 775
astctlowner = asterisk
astctlgroup = asterisk
astctl = asterisk.ctl
' > /etc/asterisk/asterisk.conf

echo '[modules]
autoload=yes
' > /etc/asterisk/modules.conf

groupadd asterisk
useradd -r -d /var/lib/asterisk -g asterisk asterisk
usermod -aG audio,dialout asterisk
chown -R asterisk.asterisk /etc/asterisk
chown -R asterisk.asterisk /var/lib/asterisk
chown -R asterisk.asterisk /var/log/asterisk
chown -R asterisk.asterisk /var/spool/asterisk
chown -R asterisk.asterisk /var/run/asterisk
chown -R asterisk.asterisk /usr/lib64/asterisk
#chown -R asterisk.asterisk /usr/lib/asterisk

###############
mcedit /etc/sysconfig/asterisk
echo 'AST_USER="asterisk"
AST_GROUP="asterisk"
' >> /etc/sysconfig/asterisk
###############
mcedit /etc/asterisk/asterisk.conf
[options]
runuser = asterisk
rungroup = asterisk

[files]
astctlpermissions = 775
astctlowner = asterisk
astctlgroup = asterisk
astctl = asterisk.ctl
###############
mcedit /etc/default/asterisk
AST_USER="asterisk"
AST_GROUP="asterisk"
###############
mcedit /etc/init.d/asterisk
AST_CONFIG=/etc/asterisk
###############

systemctl start asterisk
systemctl enable asterisk

sed -i 's";\[radius\]"\[radius\]"g' /etc/asterisk/cdr.conf
sed -i 's";radiuscfg => /usr/local/etc/radiusclient-ng/radiusclient.conf"radiuscfg => /etc/radcli/radiusclient.conf"g' /etc/asterisk/cdr.conf
sed -i 's";radiuscfg => /usr/local/etc/radiusclient-ng/radiusclient.conf"radiuscfg => /etc/radcli/radiusclient.conf"g' /etc/asterisk/cel.conf
#systemctl start asterisk
#systemctl enable asterisk
#chkconfig asterisk on

##### backup 5 #####


# freepbx install
cd /usr/src/asterisk/
tar xvfz freepbx-*.tgz
cd ./freepbx
./start_asterisk start
./install -n --dbuser root --dbpass
#./install -n
#./install

systemctl stop firewalld && systemctl disable firewalld

mcedut /etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 128M/g' /etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 128M/g' /etc/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php.ini
sed -i 's_;date.timezone =_date.timezone = "Europe/Moscow"_g' /etc/php.ini



#######################################
sed -i 's/^\(User\|Group\).*/\1 asterisk/' /etc/httpd/conf/httpd.conf
sed -i 's/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
sed -i 's/AllowOverride none/AllowOverride All/' /etc/httpd/conf/httpd.conf
chown -R asterisk:asterisk /var/spool/mqueue

#mcedit /etc/httpd/conf/httpd.conf
#User asterisk
#Group asterisk
#AllowOverride None
service httpd restart
#######################################

#add-ons
#	+format_mp3
#	+res_config_mysql
#Applications
#	+app_macro
#Codec Translators
#	+all
#PBX Modules
#	-pbx_ael
#	-pbx_dundi
#	-pbx_lua
#	-pbx_realtime
#Core Sound Packages
#	+en&ru
#Music On Hold File Packages
#	+all
#Extras Sound Packages
#	all eng

menuselect/menuselect --enable format_mp3 menuselect.makeopts
menuselect/menuselect --enable res_config_mysql menuselect.makeopts
menuselect/menuselect --enable app_macro menuselect.makeopts
menuselect/menuselect --disable pbx_ael menuselect.makeopts
menuselect/menuselect --disable pbx_dundi menuselect.makeopts
menuselect/menuselect --disable pbx_lua menuselect.makeopts
menuselect/menuselect --disable pbx_realtime menuselect.makeopts
menuselect/menuselect --enable codec_silk menuselect.makeopts
menuselect/menuselect --enable codec_siren7 menuselect.makeopts
menuselect/menuselect --enable codec_siren14 menuselect.makeopts
menuselect/menuselect --enable codec_g729a menuselect.makeopts
menuselect/menuselect --enable CORE-SOUNDS-EN-WAV menuselect.makeopts
menuselect/menuselect --enable CORE-SOUNDS-EN-ULAW menuselect.makeopts
menuselect/menuselect --enable CORE-SOUNDS-EN-ALAW menuselect.makeopts
menuselect/menuselect --enable CORE-SOUNDS-EN-GSM menuselect.makeopts
menuselect/menuselect --enable CORE-SOUNDS-EN-G729 menuselect.makeopts
menuselect/menuselect --enable CORE-SOUNDS-EN-G722 menuselect.makeopts
menuselect/menuselect --enable CORE-SOUNDS-EN-SLN16 menuselect.makeopts
menuselect/menuselect --enable CORE-SOUNDS-EN-SIREN7 menuselect.makeopts
menuselect/menuselect --enable CORE-SOUNDS-EN-SIREN14 menuselect.makeopts
menuselect/menuselect --enable CORE-SOUNDS-RU-WAV menuselect.makeopts
menuselect/menuselect --enable CORE-SOUNDS-RU-ULAW menuselect.makeopts
menuselect/menuselect --enable CORE-SOUNDS-RU-ALAW menuselect.makeopts
menuselect/menuselect --enable CORE-SOUNDS-RU-GSM menuselect.makeopts
menuselect/menuselect --enable CORE-SOUNDS-RU-G729 menuselect.makeopts
menuselect/menuselect --enable CORE-SOUNDS-RU-G722 menuselect.makeopts
menuselect/menuselect --enable CORE-SOUNDS-RU-SLN16 menuselect.makeopts
menuselect/menuselect --enable CORE-SOUNDS-RU-SIREN7 menuselect.makeopts
menuselect/menuselect --enable CORE-SOUNDS-RU-SIREN14 menuselect.makeopts
menuselect/menuselect --enable MOH-OPSOUND-WAV menuselect.makeopts
menuselect/menuselect --enable MOH-OPSOUND-ULAW menuselect.makeopts
menuselect/menuselect --enable MOH-OPSOUND-ALAW menuselect.makeopts
menuselect/menuselect --enable MOH-OPSOUND-GSM menuselect.makeopts
menuselect/menuselect --enable MOH-OPSOUND-G729 menuselect.makeopts
menuselect/menuselect --enable MOH-OPSOUND-G722 menuselect.makeopts
menuselect/menuselect --enable MOH-OPSOUND-SLN16 menuselect.makeopts
menuselect/menuselect --enable MOH-OPSOUND-SIREN7 menuselect.makeopts
menuselect/menuselect --enable MOH-OPSOUND-SIREN14 menuselect.makeopts
menuselect/menuselect --enable EXTRA-SOUNDS-EN-WAV menuselect.makeopts
menuselect/menuselect --enable EXTRA-SOUNDS-EN-ULAW menuselect.makeopts
menuselect/menuselect --enable EXTRA-SOUNDS-EN-ALAW menuselect.makeopts
menuselect/menuselect --enable EXTRA-SOUNDS-EN-GSM menuselect.makeopts
menuselect/menuselect --enable EXTRA-SOUNDS-EN-G729 menuselect.makeopts
menuselect/menuselect --enable EXTRA-SOUNDS-EN-G722 menuselect.makeopts
menuselect/menuselect --enable EXTRA-SOUNDS-EN-SLN16 menuselect.makeopts
menuselect/menuselect --enable EXTRA-SOUNDS-EN-SIREN7 menuselect.makeopts
menuselect/menuselect --enable EXTRA-SOUNDS-EN-SIREN14 menuselect.makeopts

