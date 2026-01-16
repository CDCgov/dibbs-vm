# GCP Click Ops Guide

## Prerequisites

Be­fore you get start­ed, please read the [GCP VM Requirements document](04-GCP-VM-Requirements.md).

This guide provides steps to set up a Virtual Machine (VM) instance using the DIBBs provided `.raw` VM image file in Google Cloud Platform (GCP). Please reach out to the DIBBS DevOps team if you need access to the RAW image file.

## Step 1: VM File Setup 

Please follow steps 1 through 5 as described in the [CLI Ops guide](05-GCP-VM-CLI-Ops-Instructions.md) to create and upload your VM image file. After doing so, you may return to this guide to continue.

## Step 2: Upload the Archive to Cloud Storage

You can upload the compressed file using the CLI or the GCP Portal.

**Using GCP Portal:**
1. Navigate to Cloud Storage > Buckets
2. Select the bucket you created in Step 2
3. Click Upload File and select `__PREFERREDNAME__.tar.gz`

> ⚠️ **Note**: The upload process may take up to an hour.

## Step 3: Create an Image from the Uploaded File

Once the upload is complete, create an image using the `.tar.gz` file.

**Using GCP Portal:**
1. Navigate to Compute Engine > Images
2. Click Create Image
3. Enter an image name and select Cloud Storage File as the source
4. Browse and select `__PREFERREDNAME__.tar.gz`
5. Complete the required metadata fields

## Step 4: Create a VM Instance from the Image

Now that the image is ready, create a VM instance.

> **Note**: The machine type varies by CPU size and other factors such as workloads and cost.

**Using GCP Portal:**
1. Navigate to Compute Engine > VM Instances
2. Click Create Instance
3. Enter a name and select a Machine Type
4. Under OS and Storage, select Custom Image
5. Choose your uploaded image and configure other settings
6. Click Create

## Step 5: Secure Your VM Instance

Once the VM instance is up and running, it's essential to secure it by setting up a firewall and updating credentials.

#### Verify and Configure GCP Firewall Rules

By default, the VM instance runs behind a GCP firewall. However, you should verify and configure rules to allow only necessary access.

- Identify existing rules and ensure only required ports are open:
  - SSH: 22
  - HTTP: 80
  - HTTPS: 443
  - eCR Viewer: 3000
  - Portainer management console: 9000

**Using GCP Portal:**
1. Navigate to VPC Network > Firewall Rules
2. Review existing rules and remove any that allow broad access
3. Click Create Firewall Rule, specify allowed ports, and restrict access by IP

## Step 6: Initial SSH Access and Mandatory Security Configuration

Your VM instance comes pre-configured with temporary login credentials that the DIBBs team has provided to you. **We strongly recommend changing these credentials immediately after your first login** to enhance security.

## Step 7: SSH Access and eCR Viewer setup

Please return to the [CLI Ops guide](05-GCP-VM-CLI-Ops-Instructions.md#step-9-initial-ssh-access-and-mandatory-security-configuration) and complete steps 9 and higher.

--

- **Version 1.0.0** 

- **We're humans writing docs, if you see an issue or wish something was clearer, [let us know!](https://github.com/CDCgov/dibbs-vm/issues/new/choose)**