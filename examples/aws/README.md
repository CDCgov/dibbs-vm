# AWS AMI with user-data scripts

This guide will help you launch a virtual machine (VM) in AWS using an AMI with user-data scripts.

## Steps to Launch a VM with User-Data Scripts

1. **Create a VM**:
   - Go to the EC2 web interface.
   - Click on "Launch Instance" and follow the wizard to configure your VM.
   - In the "Configure Instance Details" step, enter your user-data scripts in the "Advanced Details" section.
   - The user-data scripts will execute during the VM's initialization.

2. **Start the VM**:
    - Once the user-data scripts are added, start the VM.
    - The user-data scripts will execute during the VM's initialization.

## Example User-Data Script for eCR Viewer with AWS_PG_NON_INTEGRATED

```bash
cat > ~/dibbs-vm/docker/ecr-viewer/ecr-viewer.env<< EOF
CONFIG_NAME=AWS_PG_NON_INTEGRATED
AWS_REGION=us-east-1
ECR_BUCKET_NAME=ecr-viewer-bucket
DATABASE_URL=postgres://ecr-viewer:ecr-viewer@ecr-viewer-db:5432/ecr_viewer

EOF
```

## Example User-Data Script for eCR Viewer with AWS_SQLSERVER_NON_INTEGRATED

```bash
cat > ~/dibbs-vm/docker/ecr-viewer/ecr-viewer.env<< EOF
CONFIG_NAME=AWS_SQLSERVER_NON_INTEGRATED
AWS_REGION=us-east-1
ECR_BUCKET_NAME=ecr-viewer-bucket
SQL_SERVER_USER=sa
SQL_SERVER_PASSWORD=password
SQL_SERVER_HOST=localhost
DB_CIPHER=

EOF
```

## Example User-Data Script for eCR Viewer with AWS_INTEGRATED

```bash
cat > ~/dibbs-vm/docker/ecr-viewer/ecr-viewer.env<< EOF
CONFIG_NAME=AWS_INTEGRATED
AWS_REGION=us-east-1
ECR_BUCKET_NAME=ecr-viewer-bucket
NBS_PUB_KEY=

EOF
```
