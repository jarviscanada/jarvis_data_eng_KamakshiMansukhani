# Introduction

The Linux Cluster Monitoring Agent (LCMA) is designed to monitor and log resource usage across a cluster of Linux nodes. This system collects hardware and usage data, such as CPU, memory, and disk statistics, and stores it in a PostgreSQL database running in a Docker container. The primary users of this system are system administrators and the Linux Cluster Administration (LCA) team, who can leverage this data to analyze system performance and make informed decisions about resource allocation. The technologies used in this project include Bash scripting, Docker, PostgreSQL, and Git.

# Quick Start

/ Start a psql instance
bash psql_docker.sh create <db_username> <db_password>
bash psql_docker.sh start

/ Create tables using ddl.sql
psql -h localhost -U <db_username> -d host_agent -f ddl.sql

/ Insert hardware specs data into the DB
bash host_info.sh "localhost" 5432 "host_agent" <db_username> <db_password>

/ Insert hardware usage data into the DB
bash host_usage.sh "localhost" 5432 "host_agent" <db_username> <db_password>

/ Crontab setup to run host_usage.sh every minute
crontab -e
* * * * * bash <absolute path to host_usage.sh> "localhost" 5432 "host_agent" <db_username> <db_password> &> /tmp/host_usage.log


# Implementation


## Architecture
The architecture consists of three Linux hosts, each running a monitoring agent that collects data and sends it to a central PostgreSQL database hosted in a Docker container. Below is a diagram representing this setup:

## Scripts
psql_docker.sh
Used to manage the PostgreSQL Docker container.

/ Create a new container
bash psql_docker.sh create <db_username> <db_password>

/ Start or stop an existing container
bash psql_docker.sh {start|stop}
host_info.sh
Collects hardware information and inserts it into the host_info table.

bash host_info.sh "localhost" 5432 "host_agent" <db_username> <db_password>
host_usage.sh
Runs every minute to collect and insert system usage data into the host_usage table.

bash host_usage.sh "localhost" 5432 "host_agent" <db_username> <db_password>
crontab
Schedules the host_usage.sh script to run every minute.

/ Edit crontab
crontab -e

/ Add the following line
* * * * * bash <absolute path to host_usage.sh> "localhost" 5432 "host_agent" <db_username> <db_password> &> /tmp/host_usage.log
queries.sql
Contains SQL queries to resolve specific business problems, such as analyzing average CPU usage, identifying memory bottlenecks, and monitoring disk space trends.

# Database Modeling



# Test
Each script was tested to ensure it functions correctly:

psql_docker.sh: Created a PostgreSQL instance and verified connectivity. The instance was stopped and restarted to ensure proper functionality.
host_info.sh: Verified that hardware information was accurately inserted into the database.
host_usage.sh: Confirmed that system usage data was correctly logged in the database every minute. Test data was manually inserted to check consistency.
ddl.sql: Ensured that running the script on a fresh database created the necessary tables without errors.

# Deployment
The project is deployed using Docker for database management and Git for version control. The crontab scheduler ensures continuous data collection by running the host_usage.sh script every minute.

# Improvements
Implement functionality to detect hardware changes and update the host_info table accordingly.
Extend data collection to include network I/O statistics and application-specific usage metrics.
Add alerting mechanisms to notify users when resource usage exceeds predefined thresholds, such as low CPU idle time over extended periods.
