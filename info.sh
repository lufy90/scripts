#!/bin/bash
# By lufei at 20180801
# Getting system info.


export LANG=en_US.UTF-8

hostname=`hostname`
infodir=${hostname}-info


if [ -d $infodir ]; then
  i=0
  while [ -d ${infodir}.$i ]
    do 
      i=$((i+1))
    done
  infodir=${infodir}.$i
fi

mkdir $infodir

# system status
hostname > $infodir/hostname
date > $infodir/date
timedatectl > $infodir/timedatectl
cp /etc/*release $infodir
arch > $infodir/arch
systemctl list-unit-files > $infodir/systemctl_list-unit-files
chkconfig --list > $infodir/chkconfig_--list
sestatus -v > $infodir/sestatus_-v
dmesg > $infodir/dmesg
rpm -qa > $infodir/rpm_-qa
mount >  $infodir/mount
getenforce > $infodir/getenforce

cp /proc/cpuinfo $infodir
lscpu > $infodir/lscpu

cp /proc/meminfo $infodir
free -m > $infodir/free_-m

lspci -vvv > $infodir/lspci_-vvv

lsblk > $infodir/lsblk
blkid > $infodir/blkid
for blc in `lsblk | grep ^[a-z] | awk '{print $1}'`
  do
    smartctl -a /dev/$blc > $infodir/smartctl_-a_$blc
    hdparm -i /dev/$blc > $infodir/hdparm_-i_$blc
    hdparm -Tt /dev/$blc > $infodir/hdparm_-Tt_$blc
    hdparm -I /dev/$blc > $infodir/hdparm_-I_$blc
# get filesystem block size
  done

lsscsi -L >  $infodir/lsscsi_-L
lshal > $infodir/lshal
fdisk -l > $infodir/fdisk_-l
df -Th > $infodir/df_Th

ifconfig -a > $infodir/ifconfig_-a
#for dev in `ifconfig -a | grep -v ^' ' | grep -v ^$ | awk '{print $1}'`
for dev in `ip link show | grep ^[0-9] | cut -d : -f 2`
  do
    ethtool $dev > $infodir/ethtool_$dev
    ethtool -i $dev > $infodir/ethtool_-i_$dev
  done

cp /proc/bus/input/devices $infodir/

lsmod > $infodir/lsmod
for mod in `lsmod | awk '{print $1}' | tail -n +2`
  do
    modinfo $mod > $infodir/modinfo_$mod
  done

lsusb -vvv > $infodir/lsusb_-vvv
usb-devices > $infodir/usb-devices

lsb_release -a > $infodir/lsb_release_-a
uname -a > $infodir/uname_-a

lshw > $infodir/lshw
lshw -xml > $infodir/lshw_-xml
lshw -json -dump $infodir/lshw.db > $infodir/lshw_-json
dmidecode > $infodir/dmidecode
dmidecode -u --dump-bin $infodir/dmidecode.bin
dmidecode -q > $infodir/dmidecode_-q

cp /etc/yum.repos.d -r $infodir/

ps -ef > $infodir/ps_-ef
gcc -v > $infodir/gcc_-v 2>&1
g++ -v > $infodir/g++_-v 2>&1
gfortran -v > $infodir/gfortran_-v 2>&1
ip ad > $infodir/ip_ad 2>&1
cp ~/.bash_history $infodir/bash_history
env > $infodir/env 2>&1
# list all cd recorders.
cdrecord -scanbus
cp /proc/cmdline $infodir/
cp /boot/grub/grub.cfg $infodir/
java -version > $infodir/java_-version 2>&1
lvs > $infodir/lvs
yum list > $infodir/yum_list_$(date "+%Y%m%d")
rpm -qi kernel > $infodir/rpm_-qi_kernel
rpm -ql kernel > $infodir/rpm_-ql_kernel
ulimit -a > $infodir/ulimit_-a
cp /root/anaconda-ks.cfg $infodir/
last > $infodir/last
netstat -tunlp > $infodir/netsat_-tunlp


echo -e "\e[1mFinished!\e[0m"
echo -e "\e[1mSee $infodir\e[0m"
