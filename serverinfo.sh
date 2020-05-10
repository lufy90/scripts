#!/bin/bash
# filename: serverinfo.sh
# Author: lufei
# Date: 20200506 13:47:11

exe1() {
    local cmd="$*"
    $cmd > $infodir/${cmd// /_}
    }
exe2() {
    local cmd=$1
    $cmd 
    }

main() {
    local defdir=/tmp/$(hostname)-info
    local infodir=${1-$defdir}
    mkdir -p $infodir
    IFS=";"
    # cmdlist1 for cmds need to collect output
    local cmdlist1="ip ad;ps -ef;rpm -qa;crontab -l;netstat -nlp;systemctl list-unit-files;free -m;lsblk"
    # cmdlist2 for cmds not need to collect output
    local cmdlist2=""
    for i in $cmdlist1
    do
        IFS=" "
        exe1 $i
    done

    IFS=";"
    for i in $cmdlist2
    do
        IFS=" "
        exe2 $i
    done
    }


if [ $0 == "./serverinfo.sh" ];
then
    main $@
fi
