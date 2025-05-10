#!/bin/bash

LOG_FILE="access.log"

echo "1.  Request Counts:"
echo "----------------------------"
total_requests=$(wc -l < "$LOG_FILE")
get_requests=$(grep '"GET' "$LOG_FILE" | wc -l)
post_requests=$(grep '"POST' "$LOG_FILE" | wc -l)
echo "Total Requests: $total_requests"
echo "GET Requests: $get_requests"
echo "POST Requests: $post_requests"
echo

echo "2.  Unique IP Addresses:"
echo "----------------------------"
unique_ips=$(awk '{print $1}' "$LOG_FILE" | sort | uniq)
ip_count=$(echo "$unique_ips" | wc -l)
echo "Total Unique IPs: $ip_count"
echo
echo "GET & POST count per IP:"
for ip in $unique_ips; do
    get=$(grep "^$ip" "$LOG_FILE" | grep '"GET' | wc -l)
    post=$(grep "^$ip" "$LOG_FILE" | grep '"POST' | wc -l)
    echo "$ip - GET: $get, POST: $post"
done
echo

echo "3. Failure Requests (4xx & 5xx):"
echo "----------------------------"
failed_requests=$(awk '$9 ~ /^[45][0-9][0-9]$/' "$LOG_FILE" | wc -l)
failure_rate=$(awk -v total="$total_requests" -v fail="$failed_requests" 'BEGIN { printf "%.2f", (fail/total)*100 }')
echo "Failed Requests: $failed_requests"
echo "Failure Rate: $failure_rate%"
echo

echo "4.  Most Active IP:"
echo "----------------------------"
awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -1
echo

echo "5.  Daily Request Averages:"
echo "----------------------------"
days=$(awk -F'[][]' '{print $2}' "$LOG_FILE" | cut -d: -f1 | sort | uniq | wc -l)
avg_requests=$(awk -v total="$total_requests" -v d="$days" 'BEGIN { printf "%.2f", total/d }')
echo "Average Requests per Day: $avg_requests"
echo

echo "6.  Days with Most Failures:"
echo "----------------------------"
awk '$9 ~ /^[45]/ { split($4, d, ":"); print d[1] }' "$LOG_FILE" | sort | uniq -c | sort -nr | head
echo

echo "7.  Request by Hour:"
echo "----------------------------"
awk -F'[:[]' '{print $3":00"}' "$LOG_FILE" | sort | uniq -c | sort -k2
echo

echo "8.  Status Code Breakdown:"
echo "----------------------------"
awk '{print $9}' "$LOG_FILE" | grep -E '^[0-9]{3}$' | sort | uniq -c | sort -nr
echo

echo "9.  Most Active IP by Method:"
echo "----------------------------"
echo "GET:"
grep '"GET' "$LOG_FILE" | awk '{print $1}' | sort | uniq -c | sort -nr | head -1
echo "POST:"
grep '"POST' "$LOG_FILE" | awk '{print $1}' | sort | uniq -c | sort -nr | head -1
echo

echo "10.  Failure Patterns (hours/days):"
echo "----------------------------"
echo "By Hour:"
awk '$9 ~ /^[45]/ { split($4, a, ":"); print a[2]":00" }' "$LOG_FILE" | sort | uniq -c | sort -nr | head
echo
echo "By Day:"
awk '$9 ~ /^[45]/ { split($4, a, ":"); split(a[1], d, "/"); print d[1]"/"d[2]"/"d[3] }' "$LOG_FILE" | sort | uniq -c | sort -nr | head

