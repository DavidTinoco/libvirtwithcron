#! /bin/bash

#Arrancamos mv2 (si está arrancada /usr/bin/virsh nos dirá que ya lo está)
/usr/bin/virsh start mv2
/bin/sleep 10

#Guardamos la ip de la máquina mv1 y el nombre del dispositivo que tiene nues/usr/bin/tro volúmen den/usr/bin/tro de la máquina
ip1=`/usr/bin/virsh net-dhcp-leases br1 | /bin/grep mv1 | /usr/bin/tr -s " " | /usr/bin/cut -d " " -f 6 | /usr/bin/cut -d "/" -f 1`
vd1=`/usr/bin/ssh -i /root/.ssh/libvirt root@$ip1 lsblk | /bin/grep -v 'vda' | /bin/grep ^vd | /usr/bin/tr -s " " | /usr/bin/cut -d " " -f 1`

#Desmontamos el volumen
/bin/echo "Unmounting volume from mv1"
/usr/bin/ssh -i /root/.ssh/libvirt root@$ip1 /bin/umount /dev/$vd1

#Y lo desconectamos
/usr/bin/virsh detach-device mv1 /etc/libvirt/storage/apache.xml

#########################################
#Redimensionado del volumen
/bin/echo "Growing up volume 10MB"
/sbin/lvresize -L +10M /dev/sistema/mv1
/bin/mount /dev/sistema/mv1 /mnt
/usr/sbin/xfs_growfs /dev/sistema/mv1
/bin/umount /mnt
#########################################

#Guardamos la ip de la máquina mv2
ip2=`/usr/bin/virsh net-dhcp-leases br1 | /bin/grep mv2 | /usr/bin/tr -s " " | /usr/bin/cut -d " " -f 6 | /usr/bin/cut -d "/" -f 1`

#Conectamos el volumen a mv2
/usr/bin/virsh attach-device mv2 /etc/libvirt/storage/apache.xml

#Y guardamos el nombre del dispositivo que tiene nues/usr/bin/tro volúmen den/usr/bin/tro de la máquina
vd2=`/usr/bin/ssh -i /root/.ssh/libvirt root@$ip2 lsblk | /bin/grep -v 'vda' | /bin/grep ^vd | /usr/bin/tr -s " " | /usr/bin/cut -d " " -f 1`

#Para montarlo a continuación
/bin/echo "Mounting volume at mv2"
/usr/bin/ssh -i /root/.ssh/libvirt root@$ip2 /bin/mount /dev/$vd2 /var/www/html

#""""Parseamos"""" la línea en la que se encuentra nuestra actual regla de iptable para el acceso a nuestra web
line=`/sbin/iptables -t nat -L --line-number | /bin/grep $ip1 | /usr/bin/cut -d " " -f 1`

#Y la eliminamos
/bin/echo "Modifying iptables rules"
/sbin/iptables -t nat -D PREROUTING $line

#Para a continuación añadir la nueva regla hacia mv2
/sbin/iptables -I FORWARD -d $ip2/32 -p tcp --dport 80 -j ACCEPT
/sbin/iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to $ip2

#Apagamos mv1
/usr/bin/virsh shutdown mv1

