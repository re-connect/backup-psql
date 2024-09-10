#!/bin/bash

echo 'Starting database backup dump fetch';
. ./variables.sh
. ./functions.sh

start_timestamp

PROJECT_NAME=$1
check_requirements "$PROJECT_NAME"
get_credentials
get_dump_folder "$PROJECT_NAME"

mkdir -p "$DUMPS_FOLDER"
cd "$BACKUP_FOLDER" || exit

echo "Creating dump for $PROJECT_NAME";
PGPASSWORD="$DB_PASSWORD" pg_dump "$DB_NAME" -U "$DB_USER" -h localhost > "$DUMP_FILE_PATH"
echo 'Dump created';

archive_monthly_yearly_dumps
delete_old_dumps

end_timestamp
exit
