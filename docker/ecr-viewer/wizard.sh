#!/bin/bash

# AWS_REGION=${AWS_REGION}
# ECR_BUCKET_NAME=${ECR_BUCKET_NAME}
# APP_ENV=${APP_ENV}
# NBS_PUB_KEY=${NBS_PUB_KEY}
# NEXT_PUBLIC_BASEPATH=/ecr-viewer
# CONFIG_NAME=${CONFIG_NAME}
# DATABASE_URL=${DATABASE_URL}
# SQL_SERVER_USER=${SQL_SERVER_USER}
# SQL_SERVER_PASSWORD=${SQL_SERVER_PASSWORD}
# SQL_SERVER_HOST=${SQL_SERVER_HOST}

read -p "AWS_REGION: " choice
echo "AWS_REGION: $choice"

read -p "ECR_BUCKET_NAME: " choice
echo "ECR_BUCKET_NAME: $choice"

read -p "APP_ENV: " choice
echo "APP_ENV: $choice"

read -p "NBS_PUB_KEY: " choice
echo "NBS_PUB_KEY: $choice"

read -p "CONFIG_NAME: " choice
echo "CONFIG_NAME: $choice"

read -p "Database type (PostgreSQL, SQLServer): " choice
echo "Database type: $choice"

if [ "$choice" == "PostgreSQL" ]; then
  echo "PostgreSQL"
  read -p "DATABASE_URL: " choice
  echo "DATABASE_URL: $choice"
elif [ "$choice" == "SQLServer" ]; then
  echo "SQLServer"
  read -p "SQL_SERVER_USER: " choice
  echo "SQL_SERVER_USER: $choice"

  read -p "SQL_SERVER_PASSWORD: " choice
  echo "SQL_SERVER_PASSWORD: $choice"

  read -p "SQL_SERVER_HOST: " choice
  echo "SQL_SERVER_HOST: $choice"
else
  echo "Invalid database type. Please choose either PostgreSQL or SQLServer."
  exit 1
fi


docker compose up -d