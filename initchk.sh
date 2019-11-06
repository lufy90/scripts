#!/bin/bash
# filename: initchk.sh
# Author: lufei
# Date: 20190922 23:40:26


rpm_exist_check(){
    local rpmlist=$1
    for i in $rpmlist
    do
        rpm -qi $i > /dev/null || echo "FAIL: $i not installed!"
    done
}


rpm_file_check(){
    local rpmlist=$1
    for i in $rpmlist
    do
        rpm -qi $i > /dev/null || {
            echo "FAIL: $i not installed!" && continue
            }
        filelist=$(rpm -ql $i)
        if [[ $filelist == "(contains no files)" ]]; then continue; fi
        for f in $filelist
        do
            test -f $f || test -d $f || echo "FAIL: $f not exists in package $i"
        done
    done
}

usage(){
    cat <<-EOF >&2
Usage:
    $0 -e RPMLISTFILE    check if rpm packages in RPMLISTFILE installed.
                 -f RPMLISTFILE    check if rpm packages installed with correct files.
	EOF
    exit 0
}

main(){
    while getopts e:f:h arg
    do
        case $arg in
            e) rpm_exist_check "`cat $OPTARG | tr "\n" " "`" ;;
            f) rpm_file_check "`cat $OPTARG | tr "\n" " "`" ;;
            h) usage ;;
            \?) usage ;;
        esac
    done
}

main $@
