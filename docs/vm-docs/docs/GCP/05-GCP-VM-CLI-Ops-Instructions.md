# GCP CLI Ops Guide

## Prerequisites

Be­fore you get start­ed, please read the [GCP VM Requirements document](04-GCP-VM-Requirements.md).

This guide provides steps to set up a Virtual Machine (VM) instance using the DIBBs provided `.raw` VM image file in Google Cloud Platform (GCP). Please reach out to the DIBBS DevOps team if you need access to the RAW image file.

## Initial GCP CLI Setup

This guide assumes you're using the GCP CLI and that it's already set up and configured to run against your desired GCP account. If you need assistance setting that up, please see the official GCP docs.

[Official GCP CLI getting started docs]()

## Additional notes

### Dev Environment

Please note that these commands are targeted at and tested by Linux users, while the GCP CLI is designed to work with Windows, MacOS, and Linux you may need to adapt some commands to work on your respective OS. Some areas on conflict may be quoting, path separators and environments variables.

### Variable substitution

Please note that when you see sections of the CLI commands that looks like this: `__VARIABLE__`, it is dependent on you to name that yourself.

## Step 1: Authenticate with GCP and Enable Required APIs

Open your terminal and run the following commands:

```bash
# Authenticate with Google Cloud
gcloud auth login

# Set your project ID (replace YOUR_PROJECT_ID with your actual project ID)
gcloud config set project __PROJECTID__

# Enable necessary APIs
gcloud services enable compute.googleapis.com storage-component.googleapis.com
```

## Step 2: Create a Cloud Storage Bucket

Google requires a Cloud Storage bucket to store the VM image before importing it.

**Using Command Line:**
```bash
gsutil mb -c STANDARD -l __ZONE__ gs://__GCPBUCKET__/
```

**Using GCP Portal:**
1. Navigate to Cloud Storage > Buckets
2. Click Create Bucket and fill in the necessary details

> ⚠️ **Note**: The bucket you're creating here should differ from the storage bucket required to store FHIR data for the eCR Viewer. This bucket is mainly a repository to store the DIBBs `.raw` VM file.

## Step 3: Rename the File to disk.raw

GCP requires the file inside the archive to be named `disk.raw`. Rename it using the following commands:

```bash
mv __VMFILE__.raw disk.raw
```

After this, you should have only:
- `disk.raw`

## Step 4: Create the Compressed Archive

GCP does not support `.raw` files directly, so we need to compress the file into a `.tar.gz` archive.

Run the following command in the directory where the `disk.raw` file is located:

```bash
tar -czvf __PREFERREDNAME__.tar.gz disk.raw
```

**Example:**
```bash
tar -czvf ubuntu-2404-dibbs-ecr-viewer-v2-0-0-beta.tar.gz disk.raw
```

Where `ubuntu-2404-dibbs-ecr-viewer-v2-0-0-beta` is your preferred file name, this helps to maintain a consistent naming convention in your GCP bucket.

After this, you should have two output files:
- `disk.raw`
- `__PREFERREDNAME__.tar.gz`

## Step 5: Upload the Archive to Cloud Storage

You can upload the compressed file using the CLI or the GCP Portal.

**Using Command Line:**
```bash
gsutil cp __VMFILE__.tar.gz gs://__GCPBUCKET__/
```

> ⚠️ **Note**: The upload process may take up to an hour.

## Step 6: Create an Image from the Uploaded File

Once the upload is complete, create an image using the `.tar.gz` file.

**Using Command Line:**
```bash
gcloud compute images create __MYIMAGE__ \
  --source-uri gs://__GCPBUCKET__/__VMFILE__.tar.gz \
  --guest-os-features=UEFI_COMPATIBLE
```

## Step 7: Create a VM Instance from the Image

Now that the image is ready, create a VM instance.

**Using Command Line:**
```bash
gcloud compute instances create my-vm-instance \
  --image=__MYIMAGE__ \
  --zone=us-central1-a \
  --machine-type=e2-standard-4 \
  --boot-disk-size=20GB
```

> **Note**: The machine type varies by CPU size and other factors such as workloads and cost.

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
  --source-ranges=__YOURALLOWEDIP__
```

Replace `__YOURALLOWEDIP__` with trusted IP addresses (e.g., your organization's VPN or specific users).

## Step 9: Initial SSH Access and Mandatory Security Configuration

Your VM instance comes pre-configured with temporary login credentials that the DIBBs team has provided to you. **We strongly recommend changing these credentials immediately after your first login** to enhance security.

#### Initial SSH Access

To connect to your VM instance, use the following GCP command:

```bash
gcloud compute ssh username@___YOURINSTANCENAME___ --zone=__ZONE__ --project=__PROJECTID__
```

When prompted, enter the randomized password provided by the DIBBs team.

### Mandatory Security Steps (Complete Immediately After First Login)

#### Change the Default Password

**Using Command Line:**
```bash
sudo passwd dibbs-user
```

- Enter a strong, unique password when prompted and confirm the change.

## Step 10: Configure the DIBBs Applications

- eCR-Viewer: [Configure DIBBs Applications](dibbs-ecr-viewer-user-data.md)

#### Start the Required Services

Log in to your VM instance via SSH as described in Step 9. Once logged in, you can start the required services for DIBBs by executing:

## Conclusion

Following these steps, you should now have a fully functional Virtual Machine instance created from the provided raw VM image file. 

If you encounter issues, ensure that:
- You have the correct permissions in your GCP project
- All relevant GCP APIs are enabled
- The `.tar.gz` archive contains `disk.raw`


### Support
For further assistance, refer to the Google Cloud Documentation, and please feel free to reach out to the DIBBs team at any time. We're happy to help!

## Troubleshooting

### Common Issues
- **Upload timeout**: Large files may take up to an hour to upload
- **Permission errors**: Ensure your GCP account has Compute Engine Admin role
- **Image creation fails**: Verify the `.tar.gz` file contains only `disk.raw`

--

- **Version 1.1.1** 

- **We're humans writing docs, if you see an issue or wish something was clearer, [let us know!](https://github.com/CDCgov/dibbs-vm/issues/new/choose)**