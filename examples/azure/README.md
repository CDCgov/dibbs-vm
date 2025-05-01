# Table of Contents
- [Table of Contents](#table-of-contents)
- [Azure VM](#azure-vm)
  - [Prerequisites](#prerequisites)
  - [Steps to launch a VM and configure the Dibbs applications using provided wizard scripts](#steps-to-launch-a-vm-and-configure-the-dibbs-applications-using-provided-wizard-scripts)
  - [Steps to launch a VM and configure the Dibbs applications using User data fields](#steps-to-launch-a-vm-and-configure-the-dibbs-applications-using-user-data-fields)
  - [User Data](#user-data)
  - [eCR Viewer User Data](#ecr-viewer-user-data)
    - [AZURE\_PG\_NON\_INTEGRATED](#azure_pg_non_integrated)
    - [AZURE\_PG\_DUAL](#azure_pg_dual)
    - [AZURE\_SQLSERVER\_NON\_INTEGRATED](#azure_sqlserver_non_integrated)
    - [AZURE\_SQLSERVER\_DUAL](#azure_sqlserver_dual)
    - [AZURE\_INTEGRATED](#azure_integrated)

# Azure VM

- General guide to launch dibbs-ecr-viewer and dibbs-query-connector VMs.

## Prerequisites
- Ensure you have the necessary permissions to create VMs in your Azure account.

## Steps to launch a VM and configure the Dibbs applications using provided wizard scripts

1. **Create a VM**:
  - Go to the Azure portal.
  - Click on `Create a resource` and select `Virtual Machine`.
  - Follow the Azure wizard to configure your VM with settings that comply with your organizations requirements and launch your instance.
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
  - Go to the Azure portal.
  - Click on `Create a resource` and select `Virtual Machine`.
  - Follow the Azure wizard to configure your VM with settings that comply with your organizations requirements and launch your instance.
    - Be sure to include an ssh key and security settings that allow ssh so that you can connect to your instance and run the wizard scripts available.
  - In the `Advanced` tab, enter your user-data scripts in the `Custom data` section.
  - The user-data scripts will execute during the VM's initialization.

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

### AZURE_PG_NON_INTEGRATED
```bash
cat > ~/dibbs-vm/dibbs-ecr-viewer/dibbs-ecr-viewer.env<< EOF
CONFIG_NAME=AZURE_INTEGRATED
AZURE_STORAGE_CONNECTION_STRING=connection_string
AZURE_CONTAINER_NAME=container_name
DATABASE_URL=connection_string
AUTH_PROVIDER=ad
AUTH_CLIENT_ID=ad_client_id
AUTH_CLIENT_SECRET=ad_client_secret
AUTH_ISSUER=ad_issuer
EOF
```
### AZURE_PG_DUAL
```bash
cat > ~/dibbs-vm/dibbs-ecr-viewer/dibbs-ecr-viewer.env<< EOF
CONFIG_NAME=AZURE_PG_DUAL
AZURE_STORAGE_CONNECTION_STRING=connection_string
AZURE_CONTAINER_NAME=container_name
NBS_PUB_KEY=pub_key
DATABASE_URL=connection_string
AUTH_PROVIDER=ad
AUTH_CLIENT_ID=ad_client_id
AUTH_CLIENT_SECRET=ad_client_secret
AUTH_ISSUER=ad_issuer
EOF
```
### AZURE_SQLSERVER_NON_INTEGRATED
```bash
cat > ~/dibbs-vm/dibbs-ecr-viewer/dibbs-ecr-viewer.env<< EOF
CONFIG_NAME=AZURE_SQLSERVER_NON_INTEGRATED
AZURE_STORAGE_CONNECTION_STRING=connection_string
AZURE_CONTAINER_NAME=container_name
SQL_SERVER_USER=sa
SQL_SERVER_PASSWORD=password
SQL_SERVER_HOST=localhost
AUTH_PROVIDER=ad
AUTH_CLIENT_ID=ad_client_id
AUTH_CLIENT_SECRET=ad_client_secret
AUTH_ISSUER=ad_issuer
EOF
```
### AZURE_SQLSERVER_DUAL
```bash
cat > ~/dibbs-vm/dibbs-ecr-viewer/dibbs-ecr-viewer.env<< EOF
CONFIG_NAME=AZURE_SQLSERVER_DUAL
AZURE_STORAGE_CONNECTION_STRING=connection_string
AZURE_CONTAINER_NAME=container_name
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
### AZURE_INTEGRATED
```bash
cat > ~/dibbs-vm/dibbs-ecr-viewer/dibbs-ecr-viewer.env<< EOF
CONFIG_NAME=AZURE_INTEGRATED
AZURE_STORAGE_CONNECTION_STRING=connection_string
AZURE_CONTAINER_NAME=container_name
NBS_PUB_KEY=nbs_pub_key
EOF
```
