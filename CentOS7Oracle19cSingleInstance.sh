#/bin/bash

# Read Me ##########################################################################
# One Click Install Oracle19c Single Instance On CentOS 7.3
####################################################################################
# Run SHell First grant permission
# permission
#chmod u+x xxx.sh
# permission
#chmod 777 xxx.sh
################################################################################End#

# Install Oracle Envs ##############################################################
ORACLE_ZIP_PATH=/mnt/iso/LINUX.X64_193000_db_home.zip
SOFTDIR_ROOT=/oracle
SOFTDIR_BASE=$SOFTDIR_ROOT/app/oracle
SOFTDIR=$SOFTDIR_BASE/product/19.3.0/dbhome_1
LOGFILE=/tmp/install_oracle.log
BASE_DIR=$(pwd)
VG_NAME=rhel
################################################################################End#


# System Settings ##################################################################
####### Step 1 : Set TimeZone
#ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#if ! crontab -l |grep ntpdate &>/dev/null ; then
#    (echo "* 1 * * * ntpdate time.windows.com >/dev/null 2>&1";crontab -l) |crontab 
#fi

####### Step 1.1 : Change Host Name
#hostnamectl set-hostname wangxfa
#hostname

####### Step 2 : close selinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

####### Title : disable firewalld
if egrep "7.[0-9]" /etc/redhat-release &>/dev/null; then
    systemctl status firewalld
    systemctl stop firewalld
    systemctl disable firewalld
    systemctl status firewalld
elif egrep "6.[0-9]" /etc/redhat-release &>/dev/null; then
    service iptables stop
    chkconfig iptables off
fi

####### Step 3 : history time format
#if ! grep HISTTIMEFORMAT /etc/bashrc; then
#    echo 'export HISTTIMEFORMAT="%F %T `whoami` "' >> /etc/bashrc
#fi
 
####### Step 4 : SSH timeout
#if ! grep "TMOUT=600" /etc/profile &>/dev/null; then
#    echo "export TMOUT=600" >> /etc/profile
#fi
 
####### Step 5 : disable root remote login
#sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

####### Step 6 : disable unused service
# Check service : systemctl -t service
#               : systemctl list-unit-files -t service
#               : chkconfig --list
systemctl stop postfix
systemctl disable postfix

####### Stemp 7 : Update System
cat /etc/redhat-release
uname -a
cat /proc/version

yum -y update

cat /etc/redhat-release
uname -a
cat /proc/version

####### Step 8 : disable crontab send mail
#sed -i 's/^MAILTO=root/MAILTO=""/' /etc/crontab 
 
####### Step 9 : set openfiles limit
#if ! grep "* soft nofile 65535" /etc/security/limits.conf &>/dev/null; then
#cat >> /etc/security/limits.conf << EOF
#    * soft nofile 65535
#    * hard nofile 65535
#EOF
#fi
 
####### Step 10 : kernel setting
#cat >> /etc/sysctl.conf << EOF
#net.ipv4.tcp_syncookies = 1
#net.ipv4.tcp_max_tw_buckets = 20480
#net.ipv4.tcp_max_syn_backlog = 20480
#net.core.netdev_max_backlog = 262144
#net.ipv4.tcp_fin_timeout = 20  
#EOF
 
####### Step 11 : SWAP
#echo "0" > /proc/sys/vm/swappiness
 
####### Step 12 : install tools
#yum install gcc make autoconf vim sysstat net-tools iostat iftop iotp lrzsz -y

# Install Oracle ##################################################################
####### Step 2 : check hardware
grep MemTotal /proc/meminfo
grep SwapTotal /proc/meminfo
df -h /tmp
free -h
uname -m
df -h /dev/shm

####### Step 2 : check vg room
#vgs | grep -w ${VG_NAME} > /dev/null
#if [ $? -eq 1 ];then
#echo "vg ${VG_NAME} does not exist,please check!"
#exit 1
#fi

#_vg_left=$(vgs | grep -w ${VG_NAME} | grep [0-9]*g | awk '{print $NF}' | sed 's/\..*//')
#if [ 40 -ge ${_vg_left:-0} ];then
#echo "vg ${VG_NAME} useful room less than 40G "
#exit 1
#fi

####### Step 3 : install software needed by oracle 19c
####### Step 3.0 : package install repository in china
#mv /etc/yum.repos.d/*.repo /tmp
#echo "
#[base]
#name=CentOS-\$releasever - Base - mirrors.aliyun.com
#failovermethod=priority
#baseurl=http://mirrors.aliyun.com/centos/\$releasever/os/\$basearch/
#http://mirrors.aliyuncs.com/centos/\$releasever/os/\$basearch/
#http://mirrors.cloud.aliyuncs.com/centos/\$releasever/os/\$basearch/
#gpgcheck=1
#gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7
#
##released updates
#[updates]
#name=CentOS-\$releasever - Updates - mirrors.aliyun.com
#failovermethod=priority
#baseurl=http://mirrors.aliyun.com/centos/\$releasever/updates/\$basearch/
#http://mirrors.aliyuncs.com/centos/\$releasever/updates/\$basearch/
#http://mirrors.cloud.aliyuncs.com/centos/\$releasever/updates/\$basearch/
#gpgcheck=1
#gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7
#
##additional packages that may be useful
#[extras]
#name=CentOS-\$releasever - Extras - mirrors.aliyun.com
#failovermethod=priority
#baseurl=http://mirrors.aliyun.com/centos/\$releasever/extras/\$basearch/
#http://mirrors.aliyuncs.com/centos/\$releasever/extras/\$basearch/
#http://mirrors.cloud.aliyuncs.com/centos/\$releasever/extras/\$basearch/
#gpgcheck=1
#gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7" > /etc/yum.repos.d/CentOS-Base.repo

yum clean all
yum makecache

####### Step 3.1 : begin install
####### Check Requirements packages
#rpm --query --queryformat "%{NAME}-%{VERSION}.%{RELEASE} (%{ARCH})\n" bc binutils compat-libcap1 compat-libstdc++-33 gcc gcc-c++ glibc glibc-devel ksh libaio libaio-devel libgcc libstdc++ libstdc++-devel make sysstat elfutils-libelf elfutils-libelf-devel fontconfig-devel libxcb smartmontools libX11 libXau libXtst libXrender libXrender-devel
#yum install -y bc binutils elfutils-libelf elfutils-libelf-devel fontconfig-devel glibc glibc-devel ksh libaio libaio-devel libXrender libX11 libXau libXi libXtst libgcc librdmacm libstdc++ libstdc++-devel libxcb libibverbs make smartmontools sysstat compat-libcap1 compat-libstdc++-33 unzip
#yum -y install binutils compat-libcap1 gcc gcc-c++ glibc glibc.i686 glibc-devel glibc.i686 ksh libaio libaio.i686 libaio-devel libaio-devel.i686 libgcc libgcc.i686 libstdc++ libstdc++l7.i686 libstdc++-devel libstdc++-devel.i686 compat-libstdc++-33 compat-libstdc++-33.i686 libXi libXi.i686 libXtst libXtst.i686 make sysstat
yum install -y bc binutils compat-libcap1 compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel fontconfig-devel glibc glibc-devel ksh libaio libaio-devel libX11 libXau libXi libXtst libXrender libXrender-devel libgcc libstdc++ libstdc++-devel libxcb make smartmontools sysstat ipmiutil net-tools nfs-utils python python-configshell python-rtslib python-six targetcli

########################################
# Install UnZip
########################################
yum install -y unzip

####### Step 3.2 : Check software
rpm -qa bc binutils compat-libcap1 compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel fontconfig-devel glibc glibc-devel ksh libaio libaio-devel libX11 libXau libXi libXtst libXrender libXrender-devel libgcc libstdc++ libstdc++-devel libxcb make smartmontools sysstat ipmiutil net-tools nfs-utils python python-configshell python-rtslib python-six targetcli |wc
#for _rpm in bc binutils elfutils-libelf elfutils-libelf-devel fontconfig-devel glibc glibc-devel ksh libaio libaio-devel libXrender libX11 libXau libXi libXtst libgcc librdmacm libstdc++ libstdc++-devel libxcb libibverbs make smartmontools sysstat compat-libcap1 compat-libstdc++-33 unzip
#do
#rpm -qa | grep -w ${_rpm} >/dev/null
#if [ $? -ne 0 ]
#then
#echo "${_rpm} not installed"
#exit 2
#fi
#done


########################################
#Create Oracle Filesystem
########################################
#echo "Create Oracle Filesystem" >> $LOGFILE
#lvcreate -L 20G -n oracle ${VG_NAME}
#echo "lvcreate -L 20G -n oracle ${VG_NAME}.... OK=$?" >>$LOGFILE
#vgs >> $LOGFILE
#lvs >> $LOGFILE
#df -h >> $LOGFILE
#mkdir -p /oracle
#mkfs.xfs /dev/${VG_NAME}/oracle
#echo "mkfs.xfs /dev/${VG_NAME}/oracle...OK=$?" >> $LOGFILE
#mount /dev/${VG_NAME}/oracle /oracle
#echo "mount /dev/${VG_NAME}/oracle /oracle...OK=$?" >> $LOGFILE
#mount >> $LOGFILE
#echo "/dev/mapper/${VG_NAME}-oracle /oracle xfs defaults 0 0">> /etc/fstab

########################################
#Set kernel parameters
########################################
echo "Set kernel parameters" >> $LOGFILE
#MEMORY_SIZE=`grep MemTotal /proc/meminfo|awk -F ' ' '{print $2}'`
#MEMORY_SIZE_BYTES=`echo $MEMORY_SIZE*1024|bc`
#
#echo "
#kernel.shmall = $MEMORY_SIZE_BYTES
#kernel.shmmax = $MEMORY_SIZE_BYTES
#kernel.shmmni = 4096
#kernel.sem = 2500 32000 1024 1280
#fs.file-max = 6815744
#fs.aio-max-nr = 1048576
####net.ipv4.ip_local_port_range = 9000 65500
#net.core.rmem_default = 262144
#net.core.rmem_max = 4194304
#net.core.wmem_default = 262144
#net.core.wmem_max = 1048576
#vm.hugetlb_shm_group = 302
#" >>/etc/sysctl.conf
#/sbin/sysctl -p
MEMTOTAL=$(free -b | sed -n '2p' | awk '{print $2}')
SHMMAX=$(expr $MEMTOTAL / 2)
SHMMNI=4096
PAGESIZE=$(getconf PAGE_SIZE)

cat > /etc/sysctl.d/50-oracle.conf << EOF
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmmax = $SHMMAX
kernel.shmall = $(expr \( $SHMMAX / $PAGESIZE \) \* \( $SHMMNI / 16 \))
kernel.shmmni = $SHMMNI
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
EOF

sysctl --system

##############
# Padding
##############
#vi /etc/pam.d/login
## Line 15 Add
#session    required     pam_limits.so
#session required /lib64/security/pam_limits.so
#session required pam_limits.so

cat > /etc/security/limits.d/50-oracle.conf << EOF
oracle   soft   nofile   1024
oracle   hard   nofile   65536
oracle   soft   nproc    2047
oracle   hard   nproc    16384
oracle   soft   stack    10240
oracle   hard   stack    32768
EOF

########################################
# Create Users
########################################
i=54321; for group in oinstall dba oper backupdba dgdba kmdba asmdba asmoper asmadmin racdba; do
groupadd -g $i $group; i=$(expr $i + 1)
done

#useradd -u 54321 -g oinstall -G dba,oper,backupdba,dgdba,kmdba,asmdba,racdba -d /usr/oracle oracle
useradd -u 54321 -g oinstall -G dba,oper,backupdba,dgdba,kmdba,asmdba,racdba oracle

#### Press Password
passwd oracle

########################################
#Create Home directory and Software directory
# And grant Permission
########################################
echo "Create Home directory and Software directory" >> $LOGFILE
mkdir -p /home/oracle
chmod -R 755 /home/oracle
chown -R oracle:oinstall /home/oracle

#mkdir -p /oracle/app/oracle/product/19.3.0/dbhome_1
mkdir -p $SOFTDIR
unzip $ORACLE_ZIP_PATH -d $SOFTDIR
chown -R oracle:oinstall $SOFTDIR
#chmod -R 755 /oracle
chmod -R 755 $SOFTDIR_ROOT
chown -R oracle:oinstall $SOFTDIR_ROOT

#mkdir -p /u01/app/oracle
#chown -R oracle:oinstall /u01/app
#chmod -R 755 /u01

ls -l / >> $LOGFILE

########################################
#Create oraInst.loc
########################################
echo "Create oraInst.loc" >> $LOGFILE
cat > /etc/oraInst.loc << EOF
inventory_loc=$SOFTDIR_ROOT/app/oraInventory
inst_group=oinstall
EOF

########################################
#Create .bash_profile
########################################
echo "Create .profile" >> $LOGFILE
cat > /home/oracle/.bash_profile << EOF
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
. ~/.bashrc
fi

# User specific environment and startup programs

PATH=\$PATH:\$HOME/bin

export PATH

if [ -t 0 ]; then
stty intr ^C
fi

stty erase '^H'
umask 022
export ORACLE_SID=
export ORACLE_BASE=$SOFTDIR_BASE
export ORACLE_HOME=$SOFTDIR
export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:\$ORACLE_HOME/oracm/lib:/lib:/usr/lib
export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
export TMP=/tmp
export TMPDIR=\$TMP
export PATH=\$ORACLE_HOME/bin:\$ORACLE_HOME/OPatch:\$PATH:
export TNS_ADMIN=\$ORACLE_HOME/network/admin
export ORACLE_PATH=.:\$ORACLE_BASE/dba_scripts/sql:\$ORACLE_HOME/rdbms/admin
export SQLPATH=\$ORACLE_HOME/sqlplus/admin
export NLS_LANG="Japanese_Japan.AL32UTF8"
export ORA_NLS11=\$ORACLE_HOME/nls/data
export CLASSPATH=\$ORACLE_HOME/JRE:\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib:\$ORACLE_HOME/network/jlib
# Option if use rlwrap
#alias sqlplus='rlwrap sqlplus'
#alias rman='rlwrap rman'
#alias asmcmd='rlwrap asmcmd'
EOF

chown oracle:oinstall /home/oracle/.bash_profile

########################################
#Create Oracle Data Filesystem
########################################
#echo "Create Oracle Filesystem" >> $LOGFILE
#lvcreate -L 20G -n u01 ${VG_NAME}
#echo "lvcreate -L 20G -n u01 ${VG_NAME}.... OK=$?" >>$LOGFILE
#vgs >> $LOGFILE
#lvs >> $LOGFILE
#df -h >> $LOGFILE
#mkdir -p /u01
#mkfs.xfs /dev/${VG_NAME}/u01
#echo "mkfs.xfs /dev/${VG_NAME}/u01...OK=$?" >> $LOGFILE
#mount /dev/${VG_NAME}/u01 /u01
#chown -R oracle:oinstall /u01
#echo "mount /dev/${VG_NAME}/u01 /u01...OK=$?" >> $LOGFILE
#mount >> $LOGFILE
#echo "/dev/mapper/${VG_NAME}-u01 /u01 xfs defaults 0 0">> /etc/fstab

#################################################
# install oracle software
############################################
cd $SOFTDIR

echo "$SOFTDIR/runInstaller -silent -force -noconfig -ignorePrereq \
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v19.0.0 \
oracle.install.option=INSTALL_DB_SWONLY \
UNIX_GROUP_NAME=oinstall \
INVENTORY_LOCATION=/oracle/app/oraInventory \
ORACLE_BASE=/oracle/app/oracle \
oracle.install.db.InstallEdition=EE \
oracle.install.db.OSDBA_GROUP=dba \
oracle.install.db.OSOPER_GROUP=oper \
oracle.install.db.OSBACKUPDBA_GROUP=backupdba \
oracle.install.db.OSDGDBA_GROUP=dgdba \
oracle.install.db.OSKMDBA_GROUP=kmdba \
oracle.install.db.OSRACDBA_GROUP=racdba \
oracle.install.db.rootconfig.executeRootScript=false" >>$LOGFILE

su - oracle -c "$SOFTDIR/runInstaller -silent -force -noconfig -ignorePrereq \
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v19.0.0 \
oracle.install.option=INSTALL_DB_SWONLY \
UNIX_GROUP_NAME=oinstall \
INVENTORY_LOCATION=/oracle/app/oraInventory \
ORACLE_BASE=/oracle/app/oracle \
oracle.install.db.InstallEdition=EE \
oracle.install.db.OSDBA_GROUP=dba \
oracle.install.db.OSOPER_GROUP=oper \
oracle.install.db.OSBACKUPDBA_GROUP=backupdba \
oracle.install.db.OSDGDBA_GROUP=dgdba \
oracle.install.db.OSKMDBA_GROUP=kmdba \
oracle.install.db.OSRACDBA_GROUP=racdba \
oracle.install.db.rootconfig.executeRootScript=false "<<EOF
rootroot
EOF

#############################################
#run root.sh
############################################
/oracle/app/oracle/product/19.3.0/dbhome_1/root.sh

############################################
#create LISTENER ResponseFile /tmp/netca.rsp
############################################
cat > /tmp/netca.rsp<< EOF
[GENERAL]
RESPONSEFILE_VERSION="19.3"
CREATE_TYPE="CUSTOM"
[oracle.net.ca]
INSTALLED_COMPONENTS={"server","net8","javavm"}
INSTALL_TYPE="typical"
LISTENER_NUMBER=1
LISTENER_NAMES={"LISTENER"}
LISTENER_PROTOCOLS={"TCP;1521"}
LISTENER_START="LISTENER"
NAMING_METHODS={"TNSNAMES","ONAMES","HOSTNAME"}
NSN_NUMBER=1
NSN_NAMES={"EXTPROC_CONNECTION_DATA"}
NSN_SERVICE={"PLSExtProc"}
NSN_PROTOCOLS={"TCP;HOSTNAME;1521"} 
EOF

####################################
#create LISTENER by oracle user
####################################
su - oracle -c "netca -silent -responsefile /tmp/netca.rsp"

#####################################
#create database by oracle user
####################################
su - oracle -c "dbca -silent -createDatabase -templateName General_Purpose.dbc -responseFile NO_VALUE \
-gdbname orcl -sid orcl \
-createAsContainerDatabase TRUE \
-numberOfPDBs 1 \
-pdbName orclpdb2 \
-pdbAdminPassword orcl \
-sysPassword orcl -systemPassword orcl \
-datafileDestination '/oracle/app/oracle/oradata' \
-recoveryAreaDestination '/oracle/app/oracle/flash_recovery_area' \
-redoLogFileSize 50 \
-storageType FS \
-characterset AL32UTF8 -nationalCharacterSet AL16UTF16 \
-sampleSchema true \
-totalMemory 2048 \
-databaseType OLTP \
-emConfiguration NONE"

#####################################
# END
####################################
