#!/bin/bash

# Define paths to log files and output directory
ACCESS_LOG="/var/log/nginx/access.log"
ERROR_LOG="/var/log/nginx/error.log"
REPORT_DIR="/opt/scripts/reports"

# Ensure the local archiving directory exists
sudo mkdir -p "$REPORT_DIR"

# Generate a unique report name using a timestamp
TIMESTAMP=$(date "+%Y%m%d-%H%M%S")
REPORT_FILE="$REPORT_DIR/nginx_report_$TIMESTAMP.txt"

# 1. Compile Report Headers
echo "========================================================" >  "$REPORT_FILE"
echo "        HOURLY NGINX TRAFFIC & ERROR REPORT             " >> "$REPORT_FILE"
echo "        Generated on: $(date)                           " >> "$REPORT_FILE"
echo "========================================================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 2. Extract Total Traffic Requests
TOTAL_REQUESTS=$(wc -l < "$ACCESS_LOG")
echo "[+] TOTAL REQUESTS IN PAST HOUR: $TOTAL_REQUESTS" >> "$REPORT_FILE"
echo "--------------------------------------------------------" >> "$REPORT_FILE"

# 3. Top 3 Requested Web Pages
echo "[+] TOP 3 REQUESTED PAGES:" >> "$REPORT_FILE"
if [ "$TOTAL_REQUESTS" -gt 0 ]; then
    awk '{print $7}' "$ACCESS_LOG" | sort | uniq -c | sort -nr | head -n 3 >> "$REPORT_FILE"
else
    echo "No processing traffic recorded." >> "$REPORT_FILE"
fi
echo "--------------------------------------------------------" >> "$REPORT_FILE"

# 4. Top 3 Client IP Addresses
echo "[+] TOP 3 CLIENT IP ADDRESSES:" >> "$REPORT_FILE"
if [ "$TOTAL_REQUESTS" -gt 0 ]; then
    awk '{print $1}' "$ACCESS_LOG" | sort | uniq -c | sort -nr | head -n 3 >> "$REPORT_FILE"
else
    echo "No remote connections established." >> "$REPORT_FILE"
fi
echo "--------------------------------------------------------" >> "$REPORT_FILE"

# 5. Extract HTTP Status Code Distribution Matrix
echo "[+] HTTP STATUS CODE ROUTING DISTRIBUTION:" >> "$REPORT_FILE"
if [ "$TOTAL_REQUESTS" -gt 0 ]; then
    awk '{print $9}' "$ACCESS_LOG" | sort | uniq -c | sort -nr >> "$REPORT_FILE"
else
    echo "No execution status flags returned." >> "$REPORT_FILE"
fi
echo "--------------------------------------------------------" >> "$REPORT_FILE"

# 6. Parse and Summarize Nginx Error Engine Logs
echo "[+] ERROR VOLUME ANALYSIS:" >> "$REPORT_FILE"
TOTAL_ERRORS=$(wc -l < "$ERROR_LOG")
echo "Total Active Logging Failures: $TOTAL_ERRORS" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "Last 3 Critical System Errors Recorded:" >> "$REPORT_FILE"
tail -n 3 "$ERROR_LOG" >> "$REPORT_FILE"
echo "========================================================" >> "$REPORT_FILE"