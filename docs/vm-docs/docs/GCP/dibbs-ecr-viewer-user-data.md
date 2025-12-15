# GCP DIBBS eCR Viewer User Data

# NOTE: This is in very early stages and has not been improved for a while. We have more testing that we'd like to do. Please let us know if you're interested in this approach, we'd love to chat.

## User Data

- These User data scripts set the environment variables for the dibbs applications. They work by setting values in the `.env` files. The following files are loading on VM boot and can be edited or updated by your in perform modifications to your environments. If you need to update the settings of your dibbs application, simply edit the `.env` files referenced below or run the setup wizard script as shown above.

- Dibbs eCR Viewer: `~/dibbs-vm/dibbs-ecr-viewer/dibbs-ecr-viewer.env`

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
NBS_API_PUB_KEY=pub_key
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
### GCP_INTEGRATED
```bash
cat > ~/dibbs-vm/dibbs-ecr-viewer/dibbs-ecr-viewer.env<< EOF
CONFIG_NAME=GCP_INTEGRATED
GCP_CREDENTIALS=creds
GCP_PROJECT_ID=project_id
NBS_API_PUB_KEY=pub_key
NBS_PUB_KEY=pub_key
EOF
```
