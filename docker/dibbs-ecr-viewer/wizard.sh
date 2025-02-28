#!/bin/bash

# This script is a setup wizard for the eCR Viewer application. It guides the user through the process of configuring
# environment variables and setting up the necessary configurations for running the application using Docker Compose.
#
# Functions:
# - clear_dot_env: Clears the  file.
# - display_intro: Displays an introductory message and documentation link.
# - config_name: Prompts the user to select a configuration name from a list of options.
# - set_dot_env_var: Prompts the user to input a value for a given environment variable, with an optional default value.
# - set_dot_vars: Sets environment variables based on the selected configuration name and calls relevant functions to set additional variables.
# - confirm_vars: Displays the current environment variables and prompts the user to confirm them.
# - restart_docker_compose: Restarts Docker Compose with the updated environment variables.
# - add_env: Adds a key-value pair to the wizard_env_file file.
# - pg: Sets environment variables for PostgreSQL configuration.
# - sqlserver: Sets environment variables for SQL Server configuration.
# - nbs: Sets environment variables for NBS (National Electronic Disease Surveillance System Base System) configuration.
# - aws: Sets environment variables for AWS configuration.
# - azure: Sets environment variables for Azure configuration.
#
# The script follows these steps:
# 1. Clears the wizard_env_file file.
# 2. Displays an introductory message.
# 3. Prompts the user to select a configuration name.
# 4. Sets environment variables based on the selected configuration.
# 5. Prompts the user to confirm the environment variables.
# 6. Replaces the contents of the ecr_viewer_env_file file with the contents of the wizard_env_file file.
# 7. Restarts Docker Compose with the updated environment variables.

ecr_viewer_env_file="ecr-viewer.env"
ecr_viewer_env_file_bak="ecr-viewer.env.bak"
wizard_env_file="ecr-viewer.wizard.env"

clear_dot_env() {
  echo "" > "$wizard_env_file"
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

set_dot_env_var() {
  value=$1
  default=$2
  read -rp $'  \e[3m'"$value (default: $default):"$'\e[0m' choice
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
  if [ "$CONFIG_NAME" == "AWS_PG_NON_INTEGRATED" ]; then
    aws
    nbs
    pg
  elif [ "$CONFIG_NAME" == "AWS_SQLSERVER_NON_INTEGRATED" ]; then
    aws
    nbs
    sqlserver
  elif [ "$CONFIG_NAME" == "AWS_INTEGRATED" ]; then
    aws
    nbs
    pg
  elif [ "$CONFIG_NAME" == "AZURE_INTEGRATED" ]; then
    azure
    nbs
    pg
  elif [ "$CONFIG_NAME" == "AZURE_PG_NON_INTEGRATED" ]; then
    azure
    nbs
    pg
  elif [ "$CONFIG_NAME" == "AZURE_SQLSERVER_NON_INTEGRATED" ]; then
    azure
    nbs
    sqlserver
  else
    echo "Invalid configuration name. Please choose a valid configuration name."
    exit 1
  fi
}

confirm_vars() {
  echo -e "\e[1;33mPlease confirm the following settings:\e[0m"
  vars=$(cat "$wizard_env_file")
  echo -e "\e[1;36m$vars\e[0m"
  echo ""
  read -p "Is this information correct? (y/n): " choice
  if [ "$choice" != "y" ]; then
    echo "Please run the script again and provide the correct information."
    exit 1
  fi
  echo -e "\e[1;32mSettings confirmed. Updating your configuration.\e[0m"
  cp "$ecr_viewer_env_file" "$ecr_viewer_env_file_bak"
  cat "$wizard_env_file" > "$ecr_viewer_env_file"
  export $(cat $ecr_viewer_env_file | xargs)
}

restart_docker_compose() {
  docker compose down
  docker compose up -d
}

add_env() {
  echo "$1=$2" >> "$wizard_env_file"
}

pg() {
  set_dot_env_var "DATABASE_URL" "postgresql://postgres:password@localhost:5432/postgres"
}

sqlserver() {
  set_dot_env_var "SQL_SERVER_USER" "sa"
  set_dot_env_var "SQL_SERVER_PASSWORD" "password"
  set_dot_env_var "SQL_SERVER_HOST" "localhost"
  set_dot_env_var "DB_CIPHER" ""
}

nbs() {
  set_dot_env_var "NBS_AUTH" true
  set_dot_env_var "NBS_PUB_KEY" ""
}

aws() {
  set_dot_env_var "AWS_REGION" "us-east-1"
  set_dot_env_var "ECR_BUCKET_NAME" ""
}

azure() {
  set_dot_env_var "AZURE_STORAGE_CONNECTION_STRING" ""
  set_dot_env_var "AZURE_CONTAINER_NAME" ""
}

docker_compose_vars() {
  # parse ecr-viewer.env file for environment variables
  echo -e "\e[1;33mParsing eCR Viewer for default environment variables...\e[0m"
  echo ""
  while IFS= read -r line; do
    case $line in
      DIBBS_SERVICE=*)
        dibbs_service=$(echo "$line" | cut -d'=' -f2)
        ;;
      DIBBS_VERSION=*)
        dibbs_version=$(echo "$line" | cut -d'=' -f2)
        ;;
    esac
  done < "$ecr_viewer_env_file"
  add_env "DIBBS_SERVICE" "$dibbs_service"
  set_dot_env_var "DIBBS_VERSION" "$dibbs_version"
}

clear_dot_env
display_intro
docker_compose_vars
config_name
set_dot_vars
confirm_vars
restart_docker_compose
