#!/bin/bash

echo 'Starting database backup dump load';
. ./variables.sh
. ./functions.sh

start_timestamp

PROJECT_NAME=$1
check_requirements "$PROJECT_NAME"
get_credentials

if [ "$(sed -n 's/^APP_ENV=//p' "$ENV_FILE_PATH")" != "preprod" ]; then
    echo "Error : This should be run for preprod env only"
    exit 1
fi

PROD_PROJECT_NAME=$(echo "$PROJECT_NAME" | sed 's/_pp$//')
get_dump_folder "$PROD_PROJECT_NAME"

echo "Loading dump to preprod database for $PROJECT_NAME";
APP_DIRECTORY="$HOME/$PROJECT_NAME/current"
cd $APP_DIRECTORY && php ./bin/console doctrine:database:drop --force --env=preprod -n && cd -
cd $APP_DIRECTORY && php ./bin/console doctrine:database:create --env=preprod -n && cd -
PGPASSWORD="$DB_PASSWORD" psql "$DB_NAME" -U "$DB_USER" -h localhost < "$LAST_DUMP_PATH"
cd $APP_DIRECTORY && php ./bin/console doctrine:migrations:migrate -n && cd -
echo 'Dump copied';

end_timestamp
exit
