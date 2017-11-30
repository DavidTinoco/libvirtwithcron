#! /bin//bin/bash


stat1=`/usr/bin/virsh list --all | /bin/grep mv1 | /usr/bin/tr -s " " | /usr/bin/cut -d " " -f 4`
stat2=`/usr/bin/virsh list --all | /bin/grep mv2 | /usr/bin/tr -s " " | /usr/bin/cut -d " " -f 4`



if [[ $stat1 == 'running' ]]
then
	ip1=`/usr/bin/virsh net-dhcp-leases br1 | /bin/grep mv1 | /usr/bin/tr -s " " | /usr/bin/cut -d " " -f 6 | /usr/bin/cut -d "/" -f 1`
	memava=`/usr/bin/ssh -i /root/.ssh/libvirt root@$ip1 cat /proc/meminfo | /bin/grep MemAvailable | /usr/bin/tr -s " " | /usr/bin/cut -d " " -f 2`
	if [[ $memava -lt "30000" ]]
	then

		/bin/echo "Memory its close to be full, checking again in 10 seconds"
		/bin/sleep 10
		memava=`/usr/bin/ssh -i /root/.ssh/libvirt root@$ip1 cat /proc/meminfo | /bin/grep MemAvailable | /usr/bin/tr -s " " | /usr/bin/cut -d " " -f 2`

		if [[ $memava -lt "30000" ]]
		then
			/bin/echo "Memory still close to be full"

			/bin/echo "Moving server"

			/bin/bash /usr/local/sbin/moveserver.sh

		fi
	fi

fi


if [[ $stat2 == 'running' ]]
then

	ip2=`/usr/bin/virsh net-dhcp-leases br1 | /bin/grep mv2 | /usr/bin/tr -s " " | /usr/bin/cut -d " " -f 6 | /usr/bin/cut -d "/" -f 1`
	memava=`/usr/bin/ssh -i /root/.ssh/libvirt root@$ip2 cat /proc/meminfo | /bin/grep MemAvailable | /usr/bin/tr -s " " | /usr/bin/cut -d " " -f 2`

	if [[ $memava -lt "60000" ]]
	then

		/bin/echo "Memory its close to be full, checking again in 10 seconds"
		/bin/sleep 10
		memava=`/usr/bin/ssh -i /root/.ssh/libvirt root@$ip2 cat /proc/meminfo | /bin/grep MemAvailable | /usr/bin/tr -s " " | /usr/bin/cut -d " " -f 2`

		if [[ $memava -lt "60000" ]]
		then

			/bin/echo "Memory still close to be full"
			/bin/echo "Growing up memory"

			/usr/bin/virsh setmem mv2 2G --live

		fi

	fi
fi
