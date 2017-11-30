#! /bin/bash

/usr/bin/virsh net-start br1
/usr/bin/virsh start mv1
/bin/echo "Waiting for server be up"
/bin/sleep 10
/bin/echo "Server is up"

ip1=`/usr/bin/virsh net-dhcp-leases br1 | /bin/grep mv1 | /usr/bin/tr -s " " | /usr/bin/cut -d " " -f 6 | /usr/bin/cut -d "/" -f 1`

/usr/bin/virsh attach-device mv1 /etc/libvirt/storage/apache.xml

vd1=`/usr/bin/ssh -i /root/.ssh/libvirt root@$ip1 lsblk | /bin/grep -v 'vda' | /bin/grep ^vd | /usr/bin/tr -s " " | /usr/bin/cut -d " " -f 1`

/bin/echo "Mounting volume"
/usr/bin/ssh -i /root/.ssh/libvirt root@$ip1 /bin/mount /dev/$vd1 /var/www/html

/bin/echo "Writting iptables rules"
/sbin/iptables -I FORWARD -d $ip1/32 -p tcp --dport 80 -j ACCEPT
/sbin/iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to $ip1
