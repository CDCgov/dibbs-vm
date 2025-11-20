# GCP Guide to Setting Up a DIBBs Virtual Machine Instance

*Version 1.1*

This guide provides steps to set up a Virtual Machine (VM) instance using the DIBBs provided `.raw` VM image file in Google Cloud Platform (GCP).

## Prerequisites

1. **Install Google Cloud CLI**
   - Download and install Google Cloud CLI on your local machine/Terminal

2. **Access to Google Cloud Platform**
   - Ensure you have access to the Google Cloud Console and the appropriate permissions

3. **Receive the Raw VM Image File**
   - You should have received the `.raw` file and login credentials of the VM from the Skylight team either via the DIBBs portal or through a secure link

4. **Required GCP Setup**
   Anyone installing the GCP VM will need the following setup in advance:
   - An existing project they wish to deploy into
   - A Cloud Storage bucket that will store FHIR data for the eCR Viewer
   - A PostgreSQL database that the VM will be able to access over the network

## Step-by-Step Instructions

## Step 1: Authenticate with GCP and Enable Required APIs

Open your terminal and run the following commands:

```bash
# Authenticate with Google Cloud
gcloud auth login

# Set your project ID (replace YOUR_PROJECT_ID with your actual project ID)
gcloud config set project YOUR_PROJECT_ID

# Enable necessary APIs
gcloud services enable compute.googleapis.com storage-component.googleapis.com
```

## Step 2: Create a Cloud Storage Bucket

Google requires a Cloud Storage bucket to store the VM image before importing it.

**Using Command Line:**
```bash
gsutil mb -c STANDARD -l <Zone> gs://my-gcp-bucket/
```

**Using GCP Portal:**
1. Navigate to Cloud Storage > Buckets
2. Click Create Bucket and fill in the necessary details

> ⚠️ **Note**: The bucket you're creating here should differ from the storage bucket required to store FHIR data for the eCR Viewer. This bucket is mainly a repository to store the DIBBs `.raw` VM file.

## Step 3: Rename the File to disk.raw

GCP requires the file inside the archive to be named `disk.raw`. Rename it using the following commands:

```bash
mv <my-vm-file>.raw disk.raw
```

After this, you should have only:
- `disk.raw`

## Step 4: Create the Compressed Archive

GCP does not support `.raw` files directly, so we need to compress the file into a `.tar.gz` archive.

Run the following command in the directory where the `disk.raw` file is located:

```bash
tar -czvf <preferred name>.tar.gz disk.raw
```

**Example:**
```bash
tar -czvf ubuntu-2404-dibbs-ecr-viewer-v2-0-0-beta.tar.gz disk.raw
```

Where `ubuntu-2404-dibbs-ecr-viewer-v2-0-0-beta` is your preferred file name, this helps to maintain a consistent naming convention in your GCP bucket.

After this, you should have two output files:
- `disk.raw`
- `preferred name.tar.gz`

## Step 5: Upload the Archive to Cloud Storage

You can upload the compressed file using the CLI or the GCP Portal.

**Using Command Line:**
```bash
gsutil cp <my-vm-file>.tar.gz gs://my-gcp-bucket/
```

**Using GCP Portal:**
1. Navigate to Cloud Storage > Buckets
2. Select the bucket you created in Step 2
3. Click Upload File and select `my-vm-file.tar.gz`

> ⚠️ **Note**: The upload process may take up to an hour.

## Step 6: Create an Image from the Uploaded File

Once the upload is complete, create an image using the `.tar.gz` file.

**Using Command Line:**
```bash
gcloud compute images create <my-image> \
  --source-uri gs://<my-gcp-bucket>/<my-vm-file>.tar.gz \
  --guest-os-features=UEFI_COMPATIBLE
```

**Using GCP Portal:**
1. Navigate to Compute Engine > Images
2. Click Create Image
3. Enter an image name and select Cloud Storage File as the source
4. Browse and select `my-vm-file.tar.gz`
5. Complete the required metadata fields

## Step 7: Create a VM Instance from the Image

Now that the image is ready, create a VM instance.

**Using Command Line:**
```bash
gcloud compute instances create my-vm-instance \
  --image=<my-image> \
  --zone=us-central1-a \
  --machine-type=e2-standard-4 \
  --boot-disk-size=20GB
```

> **Note**: The machine type varies by CPU size and other factors such as workloads and cost.

**Using GCP Portal:**
1. Navigate to Compute Engine > VM Instances
2. Click Create Instance
3. Enter a name and select a Machine Type
4. Under OS and Storage, select Custom Image
5. Choose your uploaded image and configure other settings
6. Click Create

## Step 8: Secure Your VM Instance

Once the VM instance is up and running, it's essential to secure it by setting up a firewall and updating credentials.

#### Verify and Configure GCP Firewall Rules

By default, the VM instance runs behind a GCP firewall. However, you should verify and configure rules to allow only necessary access.

**Using Command Line:**
```bash
gcloud compute firewall-rules list
```

- Identify existing rules and ensure only required ports are open:
  - SSH: 22
  - HTTP: 80
  - HTTPS: 443
  - eCR Viewer: 3000
  - Orchestration service: 8085
  - Portainer management console: 9000

To restrict access, create a firewall rule:
```bash
gcloud compute firewall-rules create allow-ssh \
  --direction=INGRESS \
  --priority=1000 \
  --network=default \
  --action=ALLOW \
  --rules=tcp:22 \
  --source-ranges=<YOUR_ALLOWED_IP>
```

Replace `<YOUR_ALLOWED_IP>` with trusted IP addresses (e.g., your organization's VPN or specific users).

**Using GCP Portal:**
1. Navigate to VPC Network > Firewall Rules
2. Review existing rules and remove any that allow broad access
3. Click Create Firewall Rule, specify allowed ports, and restrict access by IP

## Step 9: Initial SSH Access and Mandatory Security Configuration

Your VM instance comes pre-configured with temporary login credentials that the DIBBs team has provided to you. **We strongly recommend changing these credentials immediately after your first login** to enhance security.

#### Initial SSH Access

To connect to your VM instance, use the following GCP command:

```bash
gcloud compute ssh username@your-instance-name --zone=your-zone --project=your-project-id
```

When prompted, enter the randomized password provided by the DIBBs team.

### Mandatory Security Steps (Complete Immediately After First Login)

#### Change the Default Password

**Using Command Line:**
```bash
sudo passwd <username> # Replace <username> with the  user's name provided to you by the DIBBs team 
```

- Enter a strong, unique password when prompted and confirm the change.

#### Alternative: Using GCP Console

1. Navigate to Compute Engine > VM Instances
2. Click on your instance
3. Under the SSH Keys section, add a new SSH key or update credentials

## Step 10: Configure the DIBBs Applications

- eCR-Viewer: [Configure DIBBs Applications](examples/gcp/dibbs-ecr-viewer.md)
- Query-Connector: [Configure DIBBs Applications](examples/gcp/dibbs-query-connector.md)

## Conclusion

Following these steps, you should now have a fully functional Virtual Machine instance created from the provided raw VM image file. 

If you encounter issues, ensure that:
- You have the correct permissions in your GCP project
- The APIs are enabled
- The `.tar.gz` archive contains `disk.raw`


### Support
For further assistance, refer to the Google Cloud Documentation, and please feel free to reach out to the DIBBs team at any time. We're happy to help!

## Troubleshooting

### Common Issues
- **Upload timeout**: Large files may take up to an hour to upload
- **Permission errors**: Ensure your GCP account has Compute Engine Admin role
- **Image creation fails**: Verify the `.tar.gz` file contains only `disk.raw`


