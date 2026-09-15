<img width="1485" height="862" alt="Screenshot 2026-09-15 at 23 43 58" src="https://github.com/user-attachments/assets/ead8d632-4f63-4628-b9be-bbd71594f2e3" />










# ASUS Router RT-AX86U Pro Monitoring

Complete monitoring solution for ASUS RT-AX86U Pro router using Telegraf, InfluxDB, and Grafana.

## Overview

This project provides real-time monitoring of your ASUS router including:
- CPU and Memory usage
- WAN connection status and traffic
- Wireless clients (2.4GHz and 5GHz)
- Connected devices (wired/wireless breakdown)
- Wireless signal quality (noise floor, link rate, transmit power)
- Disk usage (JFFS, USB drive)
- Network interface statistics
- System uptime and load

## Architecture

```
ASUS Router (RT-AX86U Pro)
    ↓
  Telegraf (collects metrics every 10s)
    ↓
  InfluxDB (stores time-series data)
    ↓
  Grafana (visualizes data)
```

## Prerequisites

- ASUS RT-AX86U Pro router with Merlin firmware
- SSH access enabled on the router
- USB drive plugged into the router (for entware/Telegraf installation)
- InfluxDB v2.x instance
- Grafana instance
- Network connectivity between router and InfluxDB

## Installation

### Step 1: Router Setup

1. **Enable SSH on your router:**
   - Go to router admin panel → Administration → System
   - Enable SSH service
   - Set SSH port (default: 22)

2. **Plug in a USB drive** to the router (for entware installation)

3. **SSH into the router:**
   ```bash
   ssh admin@192.168.0.1
   ```

4. **Run the setup script:**
   ```bash
   # Download and run the router setup script
   # This will install entware and Telegraf
   curl -O https://raw.githubusercontent.com/Networkwilliams/Asus-Router-RT-AX86U-Pro-Monitoring-/main/router-setup.sh
   chmod +x router-setup.sh
   ./router-setup.sh
   ```

### Step 2: Configure Telegraf

1. **Copy the Telegraf configuration to the router:**
   ```bash
   # On your local machine
   scp telegraf-router.conf admin@192.168.0.1:/opt/etc/telegraf.conf
   ```

2. **Edit the configuration on the router:**
   ```bash
   # SSH into router
   ssh admin@192.168.0.1

   # Edit the config
   nano /opt/etc/telegraf.conf
   ```

3. **Update these values:**
   - Line 24: `urls` - Your InfluxDB URL (default: `http://192.168.0.200:8086`)
   - Line 25: `token` - Your InfluxDB API token
   - Line 26: `organization` - Your InfluxDB organization name
   - Line 27: `bucket` - Your InfluxDB bucket name (default: `router`)

### Step 3: Install Custom Metrics Scripts

1. **Create scripts directory:**
   ```bash
   mkdir -p /opt/scripts
   ```

2. **Copy the custom scripts to the router:**
   ```bash
   # From your local machine
   scp wireless_stats.sh admin@192.168.0.1:/opt/scripts/
   scp client_stats.sh admin@192.168.0.1:/opt/scripts/
   scp wan_stats.sh admin@192.168.0.1:/opt/scripts/
   ```

3. **Make scripts executable:**
   ```bash
   # On the router
   chmod +x /opt/scripts/*.sh

   # Fix line endings and remove leading spaces from shebang
   sed -i 's/\r$//' /opt/scripts/*.sh
   sed -i '1s/^[[:space:]]*//' /opt/scripts/*.sh
   ```

### Step 4: Test Telegraf

1. **Test the configuration:**
   ```bash
   /opt/bin/telegraf --config /opt/etc/telegraf.conf --test
   ```

2. **Start Telegraf:**
   ```bash
   /opt/bin/telegraf --config /opt/etc/telegraf.conf > /tmp/telegraf.log 2>&1 &
   ```

3. **Check if it's running:**
   ```bash
   ps | grep telegraf
   tail -f /tmp/telegraf.log
   ```

### Step 5: Setup Auto-Start on Reboot

1. **Create startup script:**
   ```bash
   mkdir -p /jffs/scripts

   cat > /jffs/scripts/services-start << 'EOF'
   #!/bin/sh

   # Wait for system to be ready
   sleep 30

   # Start Telegraf
   logger -t "telegraf-startup" "Starting Telegraf"
   /opt/bin/telegraf --config /opt/etc/telegraf.conf > /tmp/telegraf.log 2>&1 &

   logger -t "telegraf-startup" "Telegraf started with PID $!"
   EOF

   chmod +x /jffs/scripts/services-start
   ```

### Step 6: Setup InfluxDB

1. **Create a bucket in InfluxDB:**
   - Login to InfluxDB UI (http://your-influxdb:8086)
   - Go to **Load Data** → **Buckets**
   - Create a new bucket named `router`

2. **Generate an API token:**
   - Go to **Load Data** → **API Tokens**
   - Click **Generate API Token** → **All Access API Token**
   - Copy the token for use in Telegraf config

### Step 7: Setup Grafana Dashboard

1. **Add InfluxDB as a data source in Grafana:**
   - Go to **☰ Menu** → **Connections** → **Data Sources**
   - Click **Add data source** → Select **InfluxDB**
   - Configure:
     - **Name:** `influxdb` (must match this exactly)
     - **Query Language:** `Flux`
     - **URL:** `http://your-influxdb:8086`
     - **Organization:** Your InfluxDB org name
     - **Token:** Your InfluxDB API token
     - **Default Bucket:** `router`
   - Click **Save & Test**

2. **Import the dashboard:**
   - Go to **☰ Menu** → **Dashboards** → **New** → **Import**
   - Upload `router-grafana-dashboard.json`
   - Click **Import**

## Dashboard Panels

The Grafana dashboard includes:

### Status Panels (Top Row)
- **WAN Status** - Connection status (1=connected, 0=disconnected)
- **Total Clients** - Number of connected devices
- **Wireless Clients** - Number of WiFi devices
- **System Uptime** - Router uptime in seconds

### Time Series Graphs
- **CPU Usage** - Real-time CPU utilization (%)
- **Memory Usage** - RAM usage percentage
- **WAN Traffic** - Upload/download bandwidth on eth0
- **Connected Clients** - Timeline of all client types
- **Wireless Clients by Band** - 2.4GHz vs 5GHz client count
- **Wireless Noise Floor** - Signal quality (dBm)
- **Wireless Link Rate** - Connection speeds (Mbps)

### Gauges
- **Disk Usage** - Storage usage for JFFS, USB drive, and data partitions

## Custom Metrics Scripts

### wireless_stats.sh
Collects wireless metrics for both 2.4GHz and 5GHz bands:
- Connected clients count
- Noise floor (dBm)
- Channel number
- Link rate (Mbps)
- Transmit power (dBm)

### client_stats.sh
Counts connected devices:
- Total clients
- Wireless clients
- Wired clients
- 2.4GHz clients
- 5GHz clients

### wan_stats.sh
Monitors WAN connection:
- Connection status
- WAN IP address
- Gateway address
- Uptime

## Troubleshooting

### Telegraf won't start
1. Check logs: `tail -f /tmp/telegraf.log`
2. Verify config syntax: `/opt/bin/telegraf --config /opt/etc/telegraf.conf --test`
3. Check InfluxDB connectivity: `curl http://your-influxdb:8086/health`

### Custom scripts timing out
If you see timeout errors for `client_stats.sh`:
1. Edit `/opt/etc/telegraf.conf`
2. Increase timeout from `5s` to `10s` in the exec plugin sections

### No data in Grafana
1. Verify data in InfluxDB:
   - Go to InfluxDB UI → Data Explorer
   - Select bucket `router`
   - Check for measurements (cpu, mem, wan, wireless, clients)
2. Test queries in Grafana Explore
3. Check data source configuration
4. Verify time range in dashboard (try "Last 15 minutes")

### Script formatting issues
If scripts have "exec format error":
```bash
# Fix line endings and shebang
sed -i 's/\r$//' /opt/scripts/*.sh
sed -i '1s/^[[:space:]]*//' /opt/scripts/*.sh
chmod +x /opt/scripts/*.sh
```

## Configuration Files

- **telegraf-router.conf** - Main Telegraf configuration
- **router-setup.sh** - Initial router setup script
- **wireless_stats.sh** - Wireless metrics collection
- **client_stats.sh** - Client counting script
- **wan_stats.sh** - WAN status monitoring
- **router-grafana-dashboard.json** - Pre-built Grafana dashboard

## Metrics Collected

### Standard Metrics (via Telegraf plugins)
- `cpu` - CPU usage per core and total
- `mem` - Memory usage
- `disk` - Disk usage and free space
- `diskio` - Disk I/O statistics
- `net` - Network interface statistics
- `netstat` - TCP/UDP connection stats
- `processes` - Process counts
- `kernel` - Kernel statistics
- `system` - System load and uptime

### Custom Metrics (via exec scripts)
- `wireless` - WiFi metrics per band
- `clients` - Connected device counts
- `wan` - WAN connection status

## Performance Impact

- **CPU Usage:** ~1-2% additional load
- **Memory:** ~10-15MB for Telegraf
- **Network:** ~5-10KB/s upload to InfluxDB
- **Disk:** ~1-2MB for Telegraf binary + scripts

## Requirements

- ASUS RT-AX86U Pro (or compatible ASUS router with Merlin firmware)
- Merlin firmware version 386.x or newer
- Minimum 128MB free RAM
- USB storage device (any size, for entware)
- InfluxDB 2.x
- Grafana 9.x or newer

## Security Considerations

1. **SSH Access:** Use strong passwords or SSH keys
2. **InfluxDB Token:** Keep your API token secure
3. **Network Access:** Ensure InfluxDB is not exposed to the internet
4. **Firewall:** Consider restricting InfluxDB access to specific IPs

## Credits

- Telegraf by InfluxData
- InfluxDB by InfluxData
- Grafana by Grafana Labs
- Entware for routers

## License

MIT License - Feel free to use and modify as needed.

## Support

For issues, questions, or contributions, please open an issue on GitHub.

## Version History

- **v1.0.0** (2026-09-15) - Initial release
  - Basic monitoring setup
  - Custom metrics scripts
  - Pre-built Grafana dashboard
  - Auto-start on reboot
