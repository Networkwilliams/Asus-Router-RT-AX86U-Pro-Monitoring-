#!/bin/sh
# Connected Clients Statistics Script for ASUS Router

# Count total clients from ARP table
total_clients=$(arp -a | grep -v incomplete | wc -l)

# Count wireless clients
wl24_clients=$(wl -i eth5 assoclist | wc -l)
wl5_clients=$(wl -i eth6 assoclist | wc -l)
wireless_clients=$((wl24_clients + wl5_clients))

# Count wired clients (total - wireless)
wired_clients=$((total_clients - wireless_clients))

# Output in InfluxDB line protocol
echo "clients,type=total count=$total_clients"
echo "clients,type=wireless count=$wireless_clients"
echo "clients,type=wired count=$wired_clients"
echo "clients,type=2.4GHz count=$wl24_clients"
echo "clients,type=5GHz count=$wl5_clients"
