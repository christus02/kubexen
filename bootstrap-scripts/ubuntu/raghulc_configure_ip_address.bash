#!/bin/bash

# Assuming Xen Tools or Citrix Tools are installed already

INTERFACE="eth0"
IP=$(xenstore-read vm-data/networks/0/ip)
NETMASK=$(xenstore-read vm-data/networks/0/netmask)
PREFIX=$(xenstore-read vm-data/networks/0/prefix)
IP_CIDR=$(xenstore-read vm-data/networks/0/ip)/$(xenstore-read vm-data/networks/0/prefix)
GATEWAY=$(xenstore-read vm-data/networks/0/gateway)
NAMESERVER="8.8.8.8"

# Netplan specific
NETPLAN_CONFIG_FILE=$(ls /etc/netplan/*.yaml)

configure_ip_and_route() {
    ip addr flush dev $INTERFACE
    ifconfig $INTERFACE $IP_CIDR up 
    route add default gw $GATEWAY dev $INTERFACE
}

is_ip_configured() {
	current_ip=$(ip addr show $INTERFACE | grep inet | awk -F ' ' '{print $2}')
	if [ "$current_ip" == "$IP_CIDR" ]
	then
		return 0
	else
		return 1
	fi
}

configure_using_netplan() {
    # Take a backup of the existing file
    cp $NETPLAN_CONFIG_FILE ${NETPLAN_CONFIG_FILE}.bck_`date +%Y%m%d%H%M`
    echo
    cat > $NETPLAN_CONFIG_FILE <<EOF
    network:
      version: 2
      renderer: networkd
      ethernets:
        ${INTERFACE}:
          addresses:
            - $IP_CIDR
          gateway4: $GATEWAY
          nameservers:
              addresses: [$NAMESERVER]
EOF
    sudo netplan apply

}

if is_ip_configured 
then
	echo "The Expected IP is already configured, so won't reconfigure again..."
else
	echo "Expected IP is not configured in the interface. Trying to configure it using Netplan..."
	configure_using_netplan
fi
