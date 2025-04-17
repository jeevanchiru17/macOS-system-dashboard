#!/bin/bash

echo "🔧 System Info"
echo "Hostname: $(hostname)"
sw_vers

# Constants
PAGE_SIZE=16384  # 16KB per page

# Function to convert pages to MB
to_mb() {
  echo $(( $1 * PAGE_SIZE / 1024 / 1024 ))
}

echo
echo "⏳SYSTEM UPTIME"
echo "--------------------------"
uptime
echo

echo "⚙️ CPU Usage Info"
echo "--------------------------"
top -l 1 | grep "CPU usage"

echo
echo "📡 Network Stats"
echo "--------------------------"
top -l 1 | grep "Networks"

echo
echo "🔍 SYSTEM MEMORY DASHBOARD"
echo "--------------------------"

vm_stat_output=$(vm_stat)

get_val() {
  echo "$vm_stat_output" | awk -v key="$1" '$0 ~ key { gsub("\\.",""); print $NF }'
}

# Memory values
pages_free=$(get_val "Pages free")
pages_active=$(get_val "Pages active")
pages_inactive=$(get_val "Pages inactive")
pages_speculative=$(get_val "Pages speculative")
pages_wired=$(get_val "Pages wired down")
pages_purgeable=$(get_val "Pages purgeable")
compressor_pages=$(get_val "Pages occupied by compressor")
compressions=$(get_val "Compressions")
decompressions=$(get_val "Decompressions")
pageins=$(get_val "Pageins")
pageouts=$(get_val "Pageouts")
swapins=$(get_val "Swapins")
swapouts=$(get_val "Swapouts")

compressor_mb=$(to_mb "$compressor_pages")
free_percent=$(awk -v free=$pages_free -v total=$((pages_free + pages_active + pages_inactive + pages_speculative + pages_wired)) 'BEGIN { printf "%.2f", (free / total) * 100 }')

# Memory Dashboard Output
echo "🧠 Memory Stats:"
echo "--------------------------"
echo "  Free Memory         : $(to_mb $pages_free) MB"
echo "  Active Memory       : $(to_mb $pages_active) MB"
echo "  Inactive Memory     : $(to_mb $pages_inactive) MB"
echo "  Wired Memory        : $(to_mb $pages_wired) MB"
echo "  Speculative Pages   : $pages_speculative pages"
echo "  Purgeable Pages     : $pages_purgeable pages"

echo
echo "💾 Compression:"
echo "  Compressor Pages    : $compressor_pages pages (${compressor_mb} MB)"
echo "  Total Compressions  : $compressions"
echo "  Total Decompressions: $decompressions"

echo
echo "🔄 Swap I/O:"
echo "  Swapins             : $swapins"
echo "  Swapouts            : $swapouts"

echo
echo "📂 File I/O:"
echo "  Pageins             : $pageins"
echo "  Pageouts            : $pageouts"

echo
echo "📊 Total RAM Free %   : ~${free_percent}%"

# Top processes
echo
echo "🔥 Top 5 Processes by CPU Usage:"
echo "--------------------------"
ps -arcwwwxo pid,command,%cpu | head -n 6

echo
echo "🧠 Top 5 Processes by Memory Usage:"
echo "--------------------------"
ps -arcwwwxo pid,command,%mem | head -n 6
