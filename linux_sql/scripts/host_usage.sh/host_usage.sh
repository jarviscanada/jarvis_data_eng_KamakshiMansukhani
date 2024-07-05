#!/bin/bash

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# Check number of arguments
if [ "$#" -ne 5 ]; then
    echo "Incorrect number of arguments provided!"
    exit 1
fi

vmstat_mb=$(vmstat --unit M)

# Collect and parse host usage data
hostname=$(hostname | tr -d '\n')
memory_free=$(echo "$vmstat_mb" | tail -n1 | awk '{print $4}' | xargs)
cpu_idle=$(echo "$vmstat_mb" | tail -n1 | awk '{print $15}' | xargs)
cpu_kernel=$(echo "$vmstat_mb" | tail -n1 | awk '{print $14}' | xargs)
disk_io=$(vmstat --unit M -d | tail -n1 | awk '{print $10}' | xargs)
disk_available=$(df -BM / | tail -n1 | awk '{print $4}' | grep -o '[0-9]*')

timestamp=$(date -u +'%Y-%m-%d %H:%M:%S')

# Declare password env var for psql container
export PGPASSWORD=$psql_password

# Debug prints
echo "Hostname: $hostname"
echo "Memory Free: $memory_free"
echo "CPU Idle: $cpu_idle"
echo "CPU Kernel: $cpu_kernel"
echo "Disk IO: $disk_io"
echo "Disk Available: $disk_available"

# Subquery to find matching id in host_info table
host_id=$(psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -t -c "SELECT id FROM host_info WHERE hostname='$hostname'")
host_id=$(echo $host_id | xargs)  # Trim any extra whitespace

# Check if host_id is null
if [ -z "$host_id" ]; then
    echo "Error: Host ID not found for hostname '$hostname'"
    exit 1
fi

# Construct command and execute it
insert_stmt="INSERT INTO host_usage(timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available)
VALUES('$timestamp', $host_id, '$memory_free', '$cpu_idle', '$cpu_kernel', '$disk_io', '$disk_available')"

psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"

exit $?


