#!/bin/bash

# This script is a setup wizard for the eCR Viewer application. It guides the user through the process of configuring
# environment variables and setting up the necessary configurations for running the application using Docker Compose.
#
# Functions:
# - clear_dot_env: Clears the .wizard file.
# - display_intro: Displays an introductory message and documentation link.
# - config_name: Prompts the user to select a configuration name from a list of options.
# - confirm_dot_env_var: Prompts the user to input a value for a given environment variable, displays the current value from .env.
# - set_dot_vars: Sets environment variables based on the selected configuration name and calls relevant functions to set additional variables.
# - confirm_update: Displays the current environment variables and prompts the user to confirm them.
# - restart_docker_compose: Restarts Docker Compose with the updated environment variables.
# - add_env: Adds a key-value pair to the dibbs_ecr_viewer_wizard file.
# - pg: Sets environment variables for PostgreSQL configuration.
# - sqlserver: Sets environment variables for SQL Server configuration.
# - nbs: Sets environment variables for NBS (National Electronic Disease Surveillance System Base System) configuration.
# - aws: Sets environment variables for AWS configuration.
# - azure: Sets environment variables for Azure configuration.
#
# The script follows these steps:
# 1. Clears the dibbs_ecr_viewer_wizard file.
# 2. Displays an introductory message.
# 3. Prompts the user to select a configuration name.
# 4. Sets environment variables based on the selected configuration.
# 5. Prompts the user to confirm the environment variables.
# 6. Replaces the contents of the dibbs_ecr_viewer_env file with the contents of the dibbs_ecr_viewer_wizard file.
# 7. Restarts Docker Compose with the updated environment variables.

docker_directory=~/dibbs-vm/docker/dibbs-ecr-viewer
dibbs_ecr_viewer_env=$docker_directory/dibbs-ecr-viewer.env
dibbs_ecr_viewer_bak=$docker_directory/dibbs-ecr-viewer.bak
dibbs_ecr_viewer_wizard=$docker_directory/dibbs-ecr-viewer.wizard

clear_dot_env() {
  echo "" > "$dibbs_ecr_viewer_wizard"
}

display_intro() {
  echo ""
  echo -e "\e[1;32m**********************************************\e[0m"
  echo -e "\e[1;32m*                                            *\e[0m"
  echo -e "\e[1;32m*\e[0m   \e[1;37mWelcome to the eCR Viewer setup wizard\e[0m   \e[1;32m*\e[0m"
  echo -e "\e[1;32m*                                            *\e[0m"
  echo -e "\e[1;32m**********************************************\e[0m"
  echo ""
  echo -e "\e[1;32mDocumentation can be found at: \e[4;36mhttps://github.com/CDCgov/dibbs-vm\e[0m"
  echo ""
}

config_name() {
  while IFS= read -r line; do
    case $line in
      CONFIG_NAME=*)
        config_name=$(echo "$line" | cut -d'=' -f2)
        ;;
    esac
  done < "$dibbs_ecr_viewer_env"
  if [ -z "$config_name" ]; then
    config_name="\e[1;33mNONE SELECTED\e[0m"
  fi
  echo -e "Current configuration: $config_name"
  echo ""
  PS3='
  Please select your CONFIG_NAME: '
  options=("AWS_PG_NON_INTEGRATED" "AWS_SQLSERVER_NON_INTEGRATED" "AWS_INTEGRATED" "AZURE_INTEGRATED" "AZURE_PG_NON_INTEGRATED" "AZURE_SQLSERVER_NON_INTEGRATED" "Quit")
  select opt in "${options[@]}"
  do
    echo ""
    echo -e "\e[1;36m  Setting: CONFIG_NAME=$opt\e[0m"
    echo ""
    case $opt in
      "AWS_PG_NON_INTEGRATED")
        CONFIG_NAME="AWS_PG_NON_INTEGRATED"
        break
        ;;
      "AWS_SQLSERVER_NON_INTEGRATED")
        CONFIG_NAME="AWS_SQLSERVER_NON_INTEGRATED"
        break
        ;;
      "AWS_INTEGRATED")
        CONFIG_NAME="AWS_INTEGRATED"
        break
        ;;
      "AZURE_INTEGRATED")
        CONFIG_NAME="AZURE_INTEGRATED"
        break
        ;;
      "AZURE_PG_NON_INTEGRATED")
        CONFIG_NAME="AZURE_PG_NON_INTEGRATED"
        break
        ;;
      "AZURE_SQLSERVER_NON_INTEGRATED")
        CONFIG_NAME="AZURE_SQLSERVER_NON_INTEGRATED"
        break
        ;;
      "Quit")
        break
        ;;
      *) echo "invalid option $REPLY";;
    esac
  done
}

confirm_dot_env_var() {
  value=$1
  default=$2
  read -rp $'  \e[3m'"$value (Current Value: $default): "$'\e[0m' choice
  if [ -z "$choice" ]; then
    choice=$default
  fi
  echo ""
  echo -e "  \e[1;36mSetting: $value=$choice\e[0m"
  echo ""
  add_env "$value" "$choice"
}

set_dot_vars() {
  add_env "CONFIG_NAME" $CONFIG_NAME
  case "$CONFIG_NAME" in
    "AWS_PG_NON_INTEGRATED")
      aws
      nbs
      pg
      ;;
    "AWS_SQLSERVER_NON_INTEGRATED")
      aws
      nbs
      sqlserver
      ;;
    "AWS_INTEGRATED")
      aws
      nbs
      pg
      ;;
    "AZURE_INTEGRATED")
      azure
      nbs
      pg
      ;;
    "AZURE_PG_NON_INTEGRATED")
      azure
      nbs
      pg
      ;;
    "AZURE_SQLSERVER_NON_INTEGRATED")
      azure
      nbs
      sqlserver
      ;;
    *)
      echo "Invalid configuration name. Please choose a valid configuration name."
      exit 1
      ;;
  esac
}

confirm_update() {
  echo -e "\e[1;33mPlease confirm the following settings:\e[0m"
  vars=$(cat "$dibbs_ecr_viewer_wizard")
  echo -e "\e[1;36m$vars\e[0m"
  echo ""
  read -p "Is this information correct? (y/n): " choice
  if [ "$choice" != "y" ]; then
    echo "Please run the script again and provide the correct information."
    exit 1
  fi
  echo -e "\e[1;32mSettings confirmed. Updating your configuration.\e[0m"
  cp "$dibbs_ecr_viewer_env" "$dibbs_ecr_viewer_bak"
  cat "$dibbs_ecr_viewer_wizard" > "$dibbs_ecr_viewer_env"
  # export the environment variables for the current session
  # needed for the docker compose file DIBBS_SERVICE and DIBBS_VERSION
  export $(cat $dibbs_ecr_viewer_env | xargs)
}

restart_docker_compose() {
  cd $docker_directory
  docker compose down
  docker compose up -d
  cd
}

add_env() {
  echo "$1=$2" >> "$dibbs_ecr_viewer_wizard"
}

pg() {
  check_var DATABASE_URL
}

sqlserver() {
  check_var SQL_SERVER_USER
  check_var SQL_SERVER_PASSWORD
  check_var SQL_SERVER_HOST
  check_var DB_CIPHER
}

nbs() {
  check_var NBS_PUB_KEY
}

aws() {
  check_var AWS_REGION
  check_var ECR_BUCKET_NAME
}

azure() {
  check_var AZURE_STORAGE_CONNECTION_STRING
  check_var AZURE_CONTAINER_NAME
}

check_var() {
  if [ "$1" == "DIBBS_SERVICE" ]; then
    echo -e "  \e[1;36mSetting: DIBBS_SERVICE=dibbs-ecr-viewer\e[0m"
    echo ""
    add_env "$1" "dibbs-ecr-viewer"
  else
    while IFS= read -r line; do
      case $line in
        $1=*)
          var=$(echo "$line" | cut -d'=' -f2)
          ;;
      esac
    done < "$dibbs_ecr_viewer_env"
    if [[ $var == "" ]]; then
      echo -e "\e[1;33m$1 is not set.\e[0m"
      echo ""
    fi
    confirm_dot_env_var "$1" "$var"
  fi
}

docker_compose_vars() {
  # parse ecr-viewer.env file for environment variables
  echo -e "\e[1;33mParsing eCR Viewer for default environment variables...\e[0m"
  echo ""
  check_var DIBBS_SERVICE
  check_var DIBBS_VERSION
}

clear_dot_env
display_intro
docker_compose_vars
config_name
set_dot_vars
confirm_update
restart_docker_compose
