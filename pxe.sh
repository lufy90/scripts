
iso=iSoftServerOS-5.1-aarch64-2020-0408-1916.iso

dnf install -y dhcp tftp-server vsftpd

cat >> /etc/dhcp/dhcpd.conf << eof
subnet 10.0.0.0 netmask 255.255.255.0 {
range 10.0.0.2 10.0.0.255;
option subnet-mask 255.255.255.0;
next-server 10.0.0.1;
default-lease-time 600;
deny unknown-clients;
}

host isoft11{
hardware ethernet 20:65:8e:6a:2c:f7;
filename "grubaa64.efi";
}
eof


ip ad ad 10.0.0.1/24 dev enp125s0f0

mount $iso /mnt

sed -i 's/anonymous_enable=NO/anonymous_enable=YES/' /etc/vsftpd.conf
chmod a+r /var/lib/tftpboot/ -R

file_server() {
	sed -i 's/anonymous_enable=NO/anonymous_enable=YES/' /etc/vsftpd.conf
	systemctl restart vsftpd
}

dhcp_server() {
	cat >> /etc/dhcp/dhcpd.conf << eof
subnet 10.0.0.0 netmask 255.255.255.0 {
range 10.0.0.2 10.0.0.255;
option subnet-mask 255.255.255.0;
next-server 10.0.0.1;
default-lease-time 600;
deny unknown-clients;
}

host isoft11{
hardware ethernet 20:65:8e:6a:2c:f7;
filename "grubaa64.efi";
}
eof
        systemctl restart dhcpd
}

tftp_server() {
	systemctl start tftp
}
