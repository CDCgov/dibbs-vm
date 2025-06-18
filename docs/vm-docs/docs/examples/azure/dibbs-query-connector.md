# Table of Contents
- [Table of Contents](#table-of-contents)
- [Azure VM](#azure-vm)
  - [Prerequisites](#prerequisites)
  - [Steps to launch a VM and configure the Dibbs applications using provided wizard scripts](#steps-to-launch-a-vm-and-configure-the-dibbs-applications-using-provided-wizard-scripts)
    - [Create a VM:](#create-a-vm)
    - [Connect to the VM:](#connect-to-the-vm)
    - [Configure the VM:](#configure-the-vm)

# Azure VM

- General guide to launch dibbs-query-connector VMs.

## Prerequisites
- Ensure you have the necessary permissions to create VMs in your Azure account.

## Steps to launch a VM and configure the Dibbs applications using provided wizard scripts

### Create a VM:
  
  - Go to the Azure portal.
  - Click on `Create a resource` and select `Virtual Machine`.
  - Follow the Azure wizard to configure your VM with settings that comply with your organizations requirements and launch your instance.
    - Be sure to include an ssh key and security settings that allow ssh so that you can connect to your instance and run the wizard scripts available.

### Connect to the VM:
  
  - After the VM is created, you can SSH into the VM using the key pair you specified during the creation process.

### Configure the VM:

  - **Query Connector** - Run the following command and follow the prompts to configure the Query Connector: `./dibbs-query-connector-wizard.sh`
