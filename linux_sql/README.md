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
To implement this project, the software development life cycle (SDLC) model was used, encompassing the phases of design, build, test, and deployment. During the planning and requirement analysis phase, I defined the project's scope and objectives by gathering requirements from clients and target users. With a clear understanding of the requirements, I converted them into work items, which were then added to the product backlog and organized into two-week sprints. The initial development process began with setting up the environment, including version control with Git, creating a Docker container, setting up a PostgreSQL database within Docker, configuring environment variables, and establishing the folder structure for scripts and SQL files.

After the environment setup, I focused on database design, creating tables to store hardware specifications (such as hostname, cpu_number, and cpu_model) and resource usage data (such as memory_free, cpu_idle, and disk_available). I wrote a ddl.sql script to automate the generation of these tables. Next, I developed the monitoring agents, starting with the host_info.sh script, which collects hardware specifications and inserts it into the database. Since these specifications are generally static, this script is designed to run only once. I then proceeded to create the host_usage.sh script, which gathers server usage data and logs it into the PostgreSQL database every minute using Linux's crontab.

Once the scripts were developed, I conducted thorough testing to ensure they functioned correctly. This included verifying that the host_info.sh script accurately collected hardware information and that the host_usage.sh script correctly logged resource usage data at the specified intervals. After confirming the scripts' functionality, I configured crontab to schedule the host_usage.sh script to run every minute, ensuring continuous monitoring. Finally, with a fully functional and tested application, I deployed the system into the production environment. This structured approach following the SDLC model ensured a reliable and efficient development process, resulting in an effective Linux Cluster Monitoring Agent.

# Architecture
The architecture consists of three Linux hosts, each running a monitoring agent that collects data and sends it to a central PostgreSQL database hosted in a Docker container. Below is a diagram representing this setup:

# Scripts
- psql_docker.sh

Used to manage the PostgreSQL Docker container.

- Create a new container

bash psql_docker.sh create <db_username> <db_password>

- Start or stop an existing container

bash psql_docker.sh {start|stop}

- host_info.sh

Collects hardware information and inserts it into the host_info table.

bash host_info.sh "localhost" 5432 "host_agent" <db_username> <db_password>
- host_usage.sh

Runs every minute to collect and insert system usage data into the host_usage table.

bash host_usage.sh "localhost" 5432 "host_agent" <db_username> <db_password>
- crontab

Schedules the host_usage.sh script to run every minute.

- Edit crontab

crontab -e

- Add the following line

* * * * * bash <absolute path to host_usage.sh> "localhost" 5432 "host_agent" <db_username> <db_password> &> /tmp/host_usage.log
queries.sql
Contains SQL queries to resolve specific business problems, such as analyzing average CPU usage, identifying memory bottlenecks, and monitoring disk space trends.

# Database Modeling

host_info Table
| Column |	Type |	Description |
| ------ | ----- | ------------ |
| id |	SERIAL |	Unique primary key, auto-incremented |
| hostname	| VARCHAR |	Name of the host machine |
| cpu_number |	INT	| Number of CPU cores |
| cpu_architecture | VARCHAR	| Architecture of the CPU |
| cpu_model	| VARCHAR	| Model name of the CPU |
| cpu_mhz	| FLOAT	| Clock speed of the CPU in MHz |
| l2_cache |	INT	| Size of the L2 cache in KB |
| timestamp	| TIMESTAMP	| Time when the hardware information was collected |
| total_mem |	INT	| Total available memory in MB |

host_usage Table
| Column	| Type	| Description |
| ------- | ----- | ----------- |
|timestamp	| TIMESTAMP	| Time when the usage data was collected |
| host_id	| INT	| Foreign key referring to the id in the host_info table |
| memory_free	| INT	| Amount of free memory in MB |
| cpu_idle	| FLOAT	| Percentage of time the CPU is idle |
| cpu_kernel	| FLOAT	| Percentage of time the CPU spends executing kernel code |
| disk_io	| INT	| Number of disk I/O operations per second|
| disk_available	| INT	| Available disk space in MB |

# Test
Each script was tested to ensure it functions correctly:

- psql_docker.sh: Created a PostgreSQL instance and verified connectivity. The instance was stopped and restarted to ensure proper functionality.
host_info.sh: Verified that hardware information was accurately inserted into the database.
- host_usage.sh: Confirmed that system usage data was correctly logged in the database every minute. Test data was manually inserted to check consistency.
- ddl.sql: Ensured that running the script on a fresh database created the necessary tables without errors.

# Deployment
The project is deployed using Docker for database management and Git for version control. The crontab scheduler ensures continuous data collection by running the host_usage.sh script every minute.

# Improvements
- Implement functionality to detect hardware changes and update the host_info table accordingly.
- Extend data collection to include network I/O statistics and application-specific usage metrics.
- Add alerting mechanisms to notify users when resource usage exceeds predefined thresholds, such as low CPU idle time over extended periods.
