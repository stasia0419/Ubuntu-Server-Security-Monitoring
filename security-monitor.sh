#!/bin/bash

# Ubuntu Server Security Monitoring Script
# Generates a system health and security report
# Author: Anastasia Stout
# ChatGPT (OpenAI) assisted with learning and troubleshooting

#Timestamp and report path variables
timestamp=$(date -u +"%Y-%m-%d_%H-%M-%S")
report_dir="$HOME/security-reports"
report_file="$report_dir/security-report-$timestamp.txt"
report_status=0

mkdir -p "$report_dir"

{
echo "Ubuntu Server Security Monitoring Report"
echo "Hostname: $(hostname)"
echo "System uptime: $(uptime -p)"
echo "Report generated (UTC): $(date -u)"
echo ""

echo "Disk Utilization"
df -h /
echo ""

echo "SSH Authentication Events (Last 24 Hours):"

# Retrieve SSH logs and verify that the journal query succeeded.
# The outer if provides error handling based on journalctl's exit status.
# The nested if handles the possible results of a successful query.
if ssh_logs=$(sudo journalctl -u ssh --since "24 hours ago" --no-pager); then

    # Filter the retrieved logs for authentication events.
    events=$(echo "$ssh_logs" | grep -Ei "Accepted password|Failed password|Invalid user")

    # Display matching events or report an empty result.
    if [ -z "$events" ]; then
        echo "No matching authentication events"
    else
        echo "$events"
    fi

else
    echo "ERROR: Unable to retrieve SSH journal entries"
    report_status=1
fi
} > "$report_file"

if [ "$report_status" -eq 0 ]; then
    echo "Report saved successfully: $report_file"
else
    echo "WARNING: Report saved with monitoring errors: $report_file"
fi

exit "$report_status"
