#!/bin/sh
# Wireless Statistics Script for ASUS Router

# Get 2.4GHz stats
wl24_assoc=$(wl -i eth5 assoclist | wc -l)
wl24_noise=$(wl -i eth5 noise | awk '{print $1}')
wl24_channel=$(wl -i eth5 channel | awk '{print $NF}')
wl24_rate=$(wl -i eth5 rate | awk '{print $1}')
wl24_txpwr=$(wl -i eth5 txpwr | awk '{print $1}')

# Get 5GHz stats
wl5_assoc=$(wl -i eth6 assoclist | wc -l)
wl5_noise=$(wl -i eth6 noise | awk '{print $1}')
wl5_channel=$(wl -i eth6 channel | awk '{print $NF}')
wl5_rate=$(wl -i eth6 rate | awk '{print $1}')
wl5_txpwr=$(wl -i eth6 txpwr | awk '{print $1}')

# Output in InfluxDB line protocol
echo "wireless,band=2.4GHz clients=$wl24_assoc,noise=$wl24_noise,channel=$wl24_channel,rate=$wl24_rate,txpwr=$wl24_txpwr"
echo "wireless,band=5GHz clients=$wl5_assoc,noise=$wl5_noise,channel=$wl5_channel,rate=$wl5_rate,txpwr=$wl5_txpwr"
