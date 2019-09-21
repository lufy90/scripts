#!/bin/bash
# filename: useradd.sh
# Author: lufei
# Date: 20190921 16:17:15



COUNT=$1
PASSWORD=abc123
NAMEPRE=tst_

usercreate(){
    for i in `seq -w $COUNT`
    do
        echo "useradd ${NAMEPRE}${i}"
        useradd ${NAMEPRE}${i}
    done
}


userdelet(){
    for i in `seq -w $COUNT`
    do
        echo "userdel -r ${NAMEPRE}${i}"
        userdel -r ${NAMEPRE}${i}
    done

}

