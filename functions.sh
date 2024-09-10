#!/bin/bash

### Requirements

check_requirements () {
  if [ "$#" -ne 1 ] || [ -z "$1" ]; then
    echo "Usage: $0 <project_name>"
    exit 1
  fi

  PROJECT_PATH=$HOME"/$1"

  if [ ! -d "$PROJECT_PATH" ]; then
    echo "Unable to find '$PROJECT'"
    exit 1
  fi

  export PROJECT_PATH
}

### Credentials

get_credentials () {
  ENV_FILE=".env.local"
  ENV_FILE_PATH="$PROJECT_PATH/shared/$ENV_FILE"
  DATABASE_URL=$(grep "DATABASE_URL" $ENV_FILE_PATH)

  DB_USER=$(echo "$DATABASE_URL" | awk -F'[/:@]' '{print $4}')
  DB_PASSWORD=$(echo "$DATABASE_URL" | awk -F'[/:@]' '{print $5}')
  DB_NAME=$(echo "$DATABASE_URL" | awk -F'[/?]' '{print $4}')

  export ENV_FILE_PATH
  export DB_USER
  export DB_PASSWORD
  export DB_NAME
}

### Backup/Archive

get_dump_folder () {
  PROJECT=$1

  export DUMPS_FOLDER=$HOME'/dumps'/$PROJECT;
  export MONTHLY_BACKUP_FOLDER=$DUMPS_FOLDER'/monthly';
  export YEARLY_BACKUP_FOLDER=$DUMPS_FOLDER'/yearly';
  DUMP_FILE_NAME=$(printf "backup_dump_%s.sql" "$CURRENT_DATE");
  export DUMP_FILE_PATH="$DUMPS_FOLDER/$DUMP_FILE_NAME";

  LAST_DUMP_NAME='';
  if [ -d "$DUMPS_FOLDER" ]; then
      LAST_DUMP_NAME=$(ls -t "$DUMPS_FOLDER"/ | head -1);
  fi
  export LAST_DUMP_PATH=$DUMPS_FOLDER/$LAST_DUMP_NAME;
}

delete_old_dumps () {
  echo 'Deleting all files that have been created more then 10 days ago';
  find "$DUMPS_FOLDER" -maxdepth 1 -mtime +15 -type f -delete
  echo 'Files deleted';
}

archive_monthly_yearly_dumps () {
  echo 'Checking if dump should be archived';

  #Check if first day of month
  dayNumber=`date '+%d'`
  monthNumber=`date '+%m'`
  #Check if first day of month
  if [ "$dayNumber" -eq 01 ]
  then
    #Check if first of january
    if [ "$monthNumber" -eq 01 ]
    then
      echo 'First day of year, moving the dump top monthly folder';
      mkdir -p "$YEARLY_BACKUP_FOLDER"
      cp "$DUMP_FILE_PATH" "$YEARLY_BACKUP_FOLDER"
    else
      echo 'First day of month, moving the dump top monthly folder';
      mkdir -p "$MONTHLY_BACKUP_FOLDER"
      cp "$DUMP_FILE_PATH" "$MONTHLY_BACKUP_FOLDER"
    fi
    else
      echo 'Regular dump, keep it in regular folder';
  fi
}

### Timestamps

start_timestamp () {
  echo '###############################';
  START_TIME=`date +%Y-%m-%d+"%T"`
  echo 'Start time : ';
  echo $START_TIME;
}

end_timestamp () {
echo 'Done';
END_TIME=`date +%Y-%m-%d+"%T"`
echo 'End time : ';
echo $END_TIME;
echo '###############################';
}