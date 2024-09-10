# Backup scripts for Psql applications

## Prerequisites

* You need to have `psql` CLI installed on the machine and `pg_dump` command available
* Preprod project directory should be formatted as `<prod_project_directory>_pp`
* Projects should contain `.env.local` file with only one `DATABASE_URL` var (remove commented ones)

## Setup

### Clone

* `mkdir dumps`
* `mkdir logs`
* `git clone git@github.com:re-connect/backup.git`
* `cd backup`
