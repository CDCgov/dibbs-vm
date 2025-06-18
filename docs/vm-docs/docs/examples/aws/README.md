# Table of Contents
- [Table of Contents](#table-of-contents)
- [AWS AMI](#aws-ami)
  - [Prerequisites](#prerequisites)
  - [Steps to launch a VM and configure the Dibbs applications using provided wizard scripts](#steps-to-launch-a-vm-and-configure-the-dibbs-applications-using-provided-wizard-scripts)
  - [Steps to launch a VM and configure the Dibbs applications using User data fields](#steps-to-launch-a-vm-and-configure-the-dibbs-applications-using-user-data-fields)
  - [User Data](#user-data)
  - [eCR Viewer User Data](#ecr-viewer-user-data)
    - [AWS\_PG\_NON\_INTEGRATED](#aws_pg_non_integrated)
    - [AWS\_PG\_DUAL](#aws_pg_dual)
    - [AWS\_SQLSERVER\_NON\_INTEGRATED](#aws_sqlserver_non_integrated)
    - [AWS\_SQLSERVER\_DUAL](#aws_sqlserver_dual)
    - [AWS\_INTEGRATED](#aws_integrated)

# AWS AMI

- General guide to launch dibbs-ecr-viewer and dibbs-query-connector VMs.

## Prerequisites
- Ensure you have the necessary permissions to create VMs in your AWS account.

## Steps to launch a VM and configure the Dibbs applications using provided wizard scripts

1. **Create a VM**:
  - Go to the EC2 web interface.
  - Click on `Launch Instance`.
  - Follow the AWS wizard to configure your VM with settings that comply with your organizations requirements and launch your instance.
    - Be sure to include an ssh key and security settings that allow ssh so that you can connect to your instance and run the wizard scripts available.

2. **Connect to the VM**:
  - After the VM is created, you can SSH into the VM using the key pair you specified during the creation process.
  - **eCR Viewer** - Run the following command and follow the prompts to configure the eCR Viewer:
    ```bash
      ./dibbs-ecr-viewer-wizard.sh
    ```
  - **Query Connector** - Run the following command and follow the prompts to configure the Query Connector:
    ```bash
      ./dibbs-query-connector-wizard.sh
    ```

## Steps to launch a VM and configure the Dibbs applications using User data fields

1. **Create a VM**:
  - Go to the EC2 web interface.
  - Click on `Launch Instance` and follow the wizard to configure your VM.
  - Follow the AWS wizard to configure your VM with settings that comply with your organizations requirements and launch your instance.
    - Be sure to include an ssh key and security settings that allow ssh so that you can connect to your instance and run the wizard scripts available.
  - In the `Advanced details` step, enter the `User data` that matches your desired configuration.
  - The `User data` scripts will execute during the VM's initialization.

2. **Verify the VM**:
  - After the VM is created, you can SSH into the VM and check the logs to verify that the user-data script executed successfully.
  - You can check the logs by running:

  - Ensure that the eCR Viewer is running and accessible.

## User Data

- These User data scripts set the environment variables for the dibbs applications. They work by setting values in the `.env` files. The following files are loading on VM boot and can be edited or updated by your in perform modifications to your environments. If you need to update the settings of your dibbs application, simply edit the `.env` files referenced below or run the setup wizard script as shown above.

- Dibbs eCR Viewer: `~/dibbs-vm/dibbs-ecr-viewer/dibbs-ecr-viewer.env`
- Dibbs Query Connector: `~/dibbs-vm/dibbs-ecr-viewer/dibbs-query-connector.env`

## eCR Viewer User Data

- The values provided in this examples are required, any environment value excluded is not required for that configuration.

### AWS_PG_NON_INTEGRATED
```bash
cat > ~/dibbs-vm/dibbs-ecr-viewer/dibbs-ecr-viewer.env<< EOF
CONFIG_NAME=AWS_PG_NON_INTEGRATED
AWS_REGION=region
ECR_BUCKET_NAME=bucket_name
DATABASE_URL=connection_string
AUTH_PROVIDER=ad
AUTH_CLIENT_ID=ad_client_id
AUTH_CLIENT_SECRET=ad_client_secret
AUTH_ISSUER=ad_issuer
EOF
```
### AWS_PG_DUAL
```bash
cat > ~/dibbs-vm/dibbs-ecr-viewer/dibbs-ecr-viewer.env<< EOF
CONFIG_NAME=AWS_PG_DUAL
AWS_REGION=region
ECR_BUCKET_NAME=bucket_name
NBS_API_PUB_KEY=pub_key
NBS_PUB_KEY=pub_key
DATABASE_URL=connection_string
AUTH_PROVIDER=ad
AUTH_CLIENT_ID=ad_client_id
AUTH_CLIENT_SECRET=ad_client_secret
AUTH_ISSUER=ad_issuer
EOF
```
### AWS_SQLSERVER_NON_INTEGRATED
```bash
cat > ~/dibbs-vm/dibbs-ecr-viewer/dibbs-ecr-viewer.env<< EOF
CONFIG_NAME=AWS_PG_DUAL
AWS_REGION=region
ECR_BUCKET_NAME=bucket_name
SQL_SERVER_USER=sa
SQL_SERVER_PASSWORD=password
SQL_SERVER_HOST=localhost
AUTH_PROVIDER=ad
AUTH_CLIENT_ID=ad_client_id
AUTH_CLIENT_SECRET=ad_client_secret
AUTH_ISSUER=ad_issuer
EOF
```
### AWS_SQLSERVER_DUAL
```bash
cat > ~/dibbs-vm/dibbs-ecr-viewer/dibbs-ecr-viewer.env<< EOF
CONFIG_NAME=AWS_PG_DUAL
AWS_REGION=region
ECR_BUCKET_NAME=bucket_name
NBS_API_PUB_KEY=pub_key
NBS_PUB_KEY=pub_key
SQL_SERVER_USER=sa
SQL_SERVER_PASSWORD=password
SQL_SERVER_HOST=localhost
AUTH_PROVIDER=ad
AUTH_CLIENT_ID=ad_client_id
AUTH_CLIENT_SECRET=ad_client_secret
AUTH_ISSUER=ad_issuer
EOF
```
### AWS_INTEGRATED
```bash
cat > ~/dibbs-vm/dibbs-ecr-viewer/dibbs-ecr-viewer.env<< EOF
CONFIG_NAME=AWS_INTEGRATED
AWS_REGION=region
ECR_BUCKET_NAME=bucket_name
NBS_API_PUB_KEY=pub_key
NBS_PUB_KEY=nbs_pub_key
EOF
```
