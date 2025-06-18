# AWS AMI DIBBS Query Connector

  - General guide to launch dibbs-query-connector VMs.

## Prerequisites

  - Ensure you have the necessary permissions to create VMs in your AWS account.

## Steps to launch a VM and configure the Dibbs applications using provided wizard scripts

### Create a VM:

  - Go to the EC2 web interface.
  - Click on `Launch Instance`.
  - Follow the AWS wizard to configure your VM with settings that comply with your organizations requirements and launch your instance.
    - Be sure to include an ssh key and security settings that allow ssh so that you can connect to your instance and run the wizard scripts available.

### Connect to the VM:

  - After the VM is created, you can SSH into the VM using the key pair you specified during the creation process.

### Configure the VM:

  - **Query Connector** - Run the following command and follow the prompts to configure the Query Connector: `./dibbs-query-connector-wizard.sh`
