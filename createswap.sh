#!/bin/bash
# filename: createswap.sh
# Author: lufei
# Date: 20200508 09:40:59

createswap() {

    [ -d `dirname $file` ] || {
        mkdir -p `dirname $file` || {
            return 1
            }
        }

    if [ -f $file ]; then
        file -sL $file | grep "swap file" || {
            echo "$file exists and not swap format"
            return 2
            }
    else    
        dd if=/dev/zero of=$file bs=${bs}M count=$((size*1024/$bs))
    fi
    mkswap $file
    
    }

startswap() {
    cat > $executstart << eof
#!/bin/bash
swapon $file
eof
    cat > $systemdscript << eof
[Unit]
Description=swap on
After=default.target

[Service]
Type=simple
RemainAfterExit=yes
ExecStart=$executstart
TimeoutStartSec=0

[Install]
WantedBy=default.target
eof
    chmod a+x $executstart
    systemctl daemon-reload
    systemctl start `basename $systemdscript`
    systemctl enable `basename $systemdscript`
}

usage() {
    cat << eof
Usage:
$0 [absfilepath] [swapsize] [fileblocksize]
absfilepath:   swap file path, /var/swap/swap.img by default
swapsize:      swap size in GB, 2GB by default
fileblocksize: create swap file by dd, here to specify bs in MB, 2M by default
eof
}

main() {
    if [ $1 == '-h' ] || [ $1 == "--help" ];then
	usage
    else
    local file=${1-/var/swap/swap.img}
    local size=${2-2}
    local bs=${3-2}
    local executstart=/usr/local/bin/swapon.sh
    local systemdscript=/etc/systemd/system/swapon.service

    createswap $file $size $bs
    startswap
    fi
}

if [ $0 == ./createswap.sh ]; then
    main $@
fi
