# Table of Contents
- [Table of Contents](#table-of-contents)
- [GCP VM](#gcp-vm)
  - [Prerequisites](#prerequisites)
  - [Steps to launch a VM and configure the Dibbs applications using provided wizard scripts](#steps-to-launch-a-vm-and-configure-the-dibbs-applications-using-provided-wizard-scripts)
  - [Steps to launch a VM and configure the Dibbs applications using User data fields](#steps-to-launch-a-vm-and-configure-the-dibbs-applications-using-user-data-fields)
  - [User Data](#user-data)
  - [eCR Viewer User Data](#ecr-viewer-user-data)
    - [GCP\_PG\_NON\_INTEGRATED](#gcp_pg_non_integrated)
    - [GCP\_PG\_DUAL](#gcp_pg_dual)
    - [GCP\_SQLSERVER\_NON\_INTEGRATED](#gcp_sqlserver_non_integrated)
    - [GCP\_SQLSERVER\_DUAL](#gcp_sqlserver_dual)
    - [GCP\_INTEGRATED](#gcp_integrated)

# GCP VM

- General guide to launch dibbs-ecr-viewer and dibbs-query-connector VMs.

## Prerequisites
- Ensure you have the necessary permissions to create VMs in your GCP project.

## Steps to launch a VM and configure the Dibbs applications using provided wizard scripts

1. **Create a VM**:
  - Go to the GCP Console.
  - Navigate to `Compute Engine` > `VM instances`.
  - Follow the GCP wizard to configure your VM with settings that comply with your organizations requirements and launch your instance.
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

## Steps to launch a VM and configure the Dibbs applications using User data fields

1. **Create a VM**:
  - Go to the GCP Console.
  - Navigate to `Compute Engine` > `VM instances`.
  - Click on `Create Instance`.
  - Follow the GCP wizard to configure your VM with settings that comply with your organizations requirements and launch your instance.
    - Be sure to include an ssh key and security settings that allow ssh so that you can connect to your instance and run the wizard scripts available.
  - In the `Management, security, disks, networking, sole tenancy` section, expand the `Metadata` section.
  - Add a new metadata entry with the key `user-data` and paste your user-data script in the value field.
  - The user-data script will execute during the VM's initialization.

2. **Verify the VM**:
  - After the VM is created, you can SSH into the VM and check the logs to verify that the user-data script executed successfully.
  - If you're using fairly recent linux distribution, you can likely check the cloud init logs here:
    ```bash
      tail -f /var/log/cloud-init-output.log
    ```
  - Ensure that the eCR Viewer is running and accessible.

## User Data

- These User data scripts set the environment variables for the dibbs applications. They work by setting values in the `.env` files. The following files are loading on VM boot and can be edited or updated by your in perform modifications to your environments. If you need to update the settings of your dibbs application, simply edit the `.env` files referenced below or run the setup wizard script as shown above.

- Dibbs eCR Viewer: `~/dibbs-vm/dibbs-ecr-viewer/dibbs-ecr-viewer.env`
- Dibbs Query Connector: `~/dibbs-vm/dibbs-ecr-viewer/dibbs-query-connector.env`

## eCR Viewer User Data

- The values provided in this examples are required, any environment value excluded is not required for that configuration.

### GCP_PG_NON_INTEGRATED
```bash
cat > ~/dibbs-vm/dibbs-ecr-viewer/dibbs-ecr-viewer.env<< EOF
CONFIG_NAME=GCP_PG_NON_INTEGRATED
GCP_CREDENTIALS=creds
GCP_PROJECT_ID=project_id
DATABASE_URL=connection_string
AUTH_PROVIDER=ad
AUTH_CLIENT_ID=ad_client_id
AUTH_CLIENT_SECRET=ad_client_secret
AUTH_ISSUER=ad_issuer
EOF
```
### GCP_PG_DUAL
```bash
cat > ~/dibbs-vm/dibbs-ecr-viewer/dibbs-ecr-viewer.env<< EOF
CONFIG_NAME=GCP_PG_DUAL
GCP_CREDENTIALS=creds
GCP_PROJECT_ID=project_id
NBS_PUB_KEY=pub_key
DATABASE_URL=connection_string
AUTH_PROVIDER=ad
AUTH_CLIENT_ID=ad_client_id
AUTH_CLIENT_SECRET=ad_client_secret
AUTH_ISSUER=ad_issuer
EOF
```
### GCP_SQLSERVER_NON_INTEGRATED
```bash
cat > ~/dibbs-vm/dibbs-ecr-viewer/dibbs-ecr-viewer.env<< EOF
CONFIG_NAME=GCP_SQLSERVER_NON_INTEGRATED
GCP_CREDENTIALS=creds
GCP_PROJECT_ID=project_id
SQL_SERVER_USER=sa
SQL_SERVER_PASSWORD=password
SQL_SERVER_HOST=localhost
AUTH_PROVIDER=ad
AUTH_CLIENT_ID=ad_client_id
AUTH_CLIENT_SECRET=ad_client_secret
AUTH_ISSUER=ad_issuer
EOF
```
### GCP_SQLSERVER_DUAL
```bash
cat > ~/dibbs-vm/dibbs-ecr-viewer/dibbs-ecr-viewer.env<< EOF
CONFIG_NAME=GCP_SQLSERVER_DUAL
GCP_CREDENTIALS=creds
GCP_PROJECT_ID=project_id
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
### GCP_INTEGRATED
```bash
cat > ~/dibbs-vm/dibbs-ecr-viewer/dibbs-ecr-viewer.env<< EOF
CONFIG_NAME=GCP_INTEGRATED
GCP_CREDENTIALS=creds
GCP_PROJECT_ID=project_id
NBS_PUB_KEY=pub_key
EOF
```
