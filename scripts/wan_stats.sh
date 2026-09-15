#!/bin/sh
# WAN Statistics Script for ASUS Router

# Get WAN status (1 = connected, 0 = disconnected)
wan_status=$(nvram get wan0_state_t)
if [ "$wan_status" = "2" ]; then
    wan_connected=1
else
    wan_connected=0
fi

# Get WAN IP
wan_ip=$(nvram get wan0_ipaddr)

# Get DNS servers
wan_dns1=$(nvram get wan0_dns | awk '{print $1}')
wan_dns2=$(nvram get wan0_dns | awk '{print $2}')

# Get gateway
wan_gateway=$(nvram get wan0_gateway)

# Get uptime
uptime_seconds=$(cat /proc/uptime | awk '{print int($1)}')

# Get WAN interface stats (ppp0 for PPPoE or eth0 for others)
if [ -d "/sys/class/net/ppp0" ]; then
    wan_iface="ppp0"
else
    wan_iface="eth0"
fi

# Output in InfluxDB line protocol
echo "wan,interface=$wan_iface connected=$wan_connected,uptime=$uptime_seconds"
echo "wan,type=ip value=\"$wan_ip\""
echo "wan,type=gateway value=\"$wan_gateway\""
