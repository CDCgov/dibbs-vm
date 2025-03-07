# Azure

## Steps to Launch a VM

1. **Create a VM**:

2. **Start the VM**:

## Example User-Data Script for eCR Viewer with AZURE_INTEGRATED

```bash
echo "CONFIG_NAME=AZURE_INTEGRATED" >> ~/dibbs-vm/docker/ecr-viewer/ecr-viewer.env
```

## Example User-Data Script for eCR Viewer with AZURE_PG_NON_INTEGRATED

```bash
echo "CONFIG_NAME=AZURE_PG_NON_INTEGRATED" >> ~/dibbs-vm/docker/ecr-viewer/ecr-viewer.env
```

## Example User-Data Script for eCR Viewer with AZURE_SQLSERVER_NON_INTEGRATED

```bash
echo "CONFIG_NAME=AZURE_SQLSERVER_NON_INTEGRATED" >> ~/dibbs-vm/docker/ecr-viewer/ecr-viewer.env
```
