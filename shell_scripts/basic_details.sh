#!/usr/bin/env bash

# -----------------------------
#  Linux System Information
# -----------------------------

# Username
username=$(whoami)

# Uptime (pretty format)
uptime=$(uptime -p | sed "s/up //")

# Temperature (sensors → fallback to thermal_zone)
temp=$(sensors 2>/dev/null | awk '/Package id 0/ {print $4}' | head -n1)
if [ -z "$temp" ]; then
    temp=$(awk '{print $1/1000"°C"}' /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n1)
fi

# Memory (human readable)
read mem_total mem_used mem_free <<<$(free -h | awk 'NR==2 {print $2, $3, $7}')

# -----------------------------
# Disk information (internal only)
# -----------------------------
disk_json=""

while read src size used avail pcent target; do
    echo "$src" | grep -q "^/dev/" || continue

    parent=$(lsblk -no PKNAME "$src" 2>/dev/null)
    [ -z "$parent" ] && parent=$(basename "$src")

    tran=$(lsblk -dno TRAN "/dev/$parent" 2>/dev/null)
    rm=$(lsblk -dno RM "/dev/$parent" 2>/dev/null)
    fstype=$(lsblk -no FSTYPE "$src" 2>/dev/null)

    # Skip USB drives — keep internal disks only
    if [ "$tran" != "usb" ]; then
        entry="{\"filesystem\":\"$src\",\"size\":\"$size\",\"used\":\"$used\",\"avail\":\"$avail\",\"use%\":\"$pcent\",\"mount\":\"$target\",\"fstype\":\"$fstype\",\"device\":\"$parent\",\"transport\":\"$tran\",\"removable\":$rm}"

        if [ -z "$disk_json" ]; then
            disk_json="$entry"
        else
            disk_json="$disk_json,$entry"
        fi
    fi

done < <(df -hl --exclude-type=overlay --output=source,size,used,avail,pcent,target | tail -n +2)


# ----------------- CPU METRICS -----------------

# CPU model
cpu_model=$(awk -F: '/model name/ {print $2; exit}' /proc/cpuinfo | sed 's/^ //')

# CPU cores
cpu_cores=$(nproc --all)

# Bogomips (rough CPU score)
cpu_bogomips=$(awk -F: '/bogomips/ {print $2; exit}' /proc/cpuinfo | sed 's/^ //')

# Current CPU frequency (kHz → MHz)
cpu_freq=$(awk '{printf "%.0f", $1/1000}' /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null)

# CPU usage (sample twice)
read cpu_user1 cpu_nice1 cpu_system1 cpu_idle1 cpu_iow1 cpu_irq1 cpu_sirq1 <<<$(awk '/^cpu / {print $2,$3,$4,$5,$6,$7,$8}' /proc/stat)
sleep 1
read cpu_user2 cpu_nice2 cpu_system2 cpu_idle2 cpu_iow2 cpu_irq2 cpu_sirq2 <<<$(awk '/^cpu / {print $2,$3,$4,$5,$6,$7,$8}' /proc/stat)

cpu_delta=$(( (cpu_user2+cpu_nice2+cpu_system2+cpu_iow2+cpu_irq2+cpu_sirq2) - (cpu_user1+cpu_nice1+cpu_system1+cpu_iow1+cpu_irq1+cpu_sirq1) ))
idle_delta=$(( cpu_idle2 - cpu_idle1 ))
cpu_usage=$(( 100 * (cpu_delta - idle_delta) / cpu_delta ))

# 1, 5, 15 min load averages
read load1 load5 load15 _ < /proc/loadavg

# CPU JSON
cpu_json=$(printf '{"model":"%s","cores":%s,"usage":%s,"load":[%s,%s,%s],"bogomips":"%s","freq_mhz":"%s"}' \
  "$cpu_model" "$cpu_cores" "$cpu_usage" "$load1" "$load5" "$load15" "$cpu_bogomips" "$cpu_freq")



# -----------------------------
# Network information (speed + ping)
# -----------------------------

# Get active interface
# Get active network interface with error handling
get_active_interface() {
    local iface
    iface=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}')
    if [ -z "$iface" ] || [ ! -d "/sys/class/net/$iface" ]; then
        echo "No active network interface found" >&2
        return 1
    fi
    echo "$iface"
}

# Read network statistics safely
read_net_stats() {
    local iface=$1
    local rx tx
    rx=$(cat "/sys/class/net/$iface/statistics/rx_bytes" 2>/dev/null)
    tx=$(cat "/sys/class/net/$iface/statistics/tx_bytes" 2>/dev/null)
    if [ -z "$rx" ] || [ -z "$tx" ]; then
        echo "Failed to read network statistics" >&2
        return 1
    fi
    echo "$rx $tx"
}

# Convert bytes per second to human readable format using awk
human_speed() {
    local bytes_per_sec=$1
    if [ "$bytes_per_sec" -ge 1048576 ]; then
        awk -v bps="$bytes_per_sec" 'BEGIN {printf "%.2f MB/s", bps/1048576}'
    elif [ "$bytes_per_sec" -ge 1024 ]; then
        awk -v bps="$bytes_per_sec" 'BEGIN {printf "%.2f KB/s", bps/1024}'
    else
        printf "%d B/s" "$bytes_per_sec"
    fi
}

# Measure ping with validation
measure_ping() {
    local ping_time
    ping_time=$(ping -c1 -W1 8.8.8.8 2>/dev/null | grep "time=" | sed 's/.*time=\([0-9.]*\).*/\1/')
    # Validate it's a valid number
    if [[ $ping_time =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo "$ping_time"
    else
        echo "0"
    fi
}

# Main network measurement logic
iface=$(get_active_interface)
if [ $? -ne 0 ]; then
    # Handle error case - set defaults
    down_raw=0
    up_raw=0
    ping_raw=0
else
    # Read initial statistics
    read rx1 tx1 <<< $(read_net_stats "$iface")
    sleep 1
    # Read final statistics
    read rx2 tx2 <<< $(read_net_stats "$iface")

    down_raw=$((rx2 - rx1))
    up_raw=$((tx2 - tx1))


    ping_raw=$(measure_ping)
fi


# -----------------------------
# Output final JSON
# -----------------------------

printf "{"
printf "\"username\":\"%s\"," "$username"
printf "\"uptime\":\"%s\"," "$uptime"
printf "\"temperature\":\"%s\"," "$temp"
printf "\"ram\":{\"available\":\"%s\",\"used\":\"%s\",\"size\":\"%s\"}," "$mem_free" "$mem_used" "$mem_total"
printf "\"disk\":[%s]," "$disk_json"
printf "\"network\":{"
printf "\"download\":{\"value\":%s,\"unit\":\"B/s\"}," "$down_raw"
printf "\"upload\":{\"value\":%s,\"unit\":\"B/s\"}," "$up_raw"
printf "\"ping\":{\"value\":%s,\"unit\":\"ms\"}" "$ping_raw"
printf "},"
printf "\"cpu\":%s" "$cpu_json"
printf "}\n"
