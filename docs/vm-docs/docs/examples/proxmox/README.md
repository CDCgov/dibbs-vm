# Table of Contents
- [Table of Contents](#table-of-contents)
- [Proxmox VM](#proxmox-vm)
  - [Prerequisites](#prerequisites)
  - [Steps to launch a VM and configure the Dibbs applications using provided wizard scripts](#steps-to-launch-a-vm-and-configure-the-dibbs-applications-using-provided-wizard-scripts)

# Proxmox VM

- General guide to launch dibbs-ecr-viewer and dibbs-query-connector VMs.

## Prerequisites

- Ensure you have the necessary permissions to create VMs in your proxmox environment.

## Steps to launch a VM and configure the Dibbs applications using provided wizard scripts

1. **Create a VM**:

2. **Connect to the VM**:
  - **eCR Viewer** - Run the following command and follow the prompts to configure the eCR Viewer:
    ```bash
      ./dibbs-ecr-viewer-wizard.sh
    ```
  - **Query Connector** - Run the following command and follow the prompts to configure the Query Connector:
    ```bash
      ./dibbs-query-connector-wizard.sh
    ```
