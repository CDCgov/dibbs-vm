
# sudo apt install genisoimage
mkdir -p /media/cdrom
mkdir -p tmp

cp ../packer/ubuntu-server/build/os-base/ubuntu-2404-ecrViewer.raw tmp/ubuntu-2404-ecrviewer.raw

# Set up loop device manually
sudo losetup -P /dev/loop0 tmp/ubuntu-2404-ecrviewer.raw

# Check for partitions and mount the first partition
if [ -e /dev/loop0p1 ]; then
    sudo mount /dev/loop0p1 /media/cdrom
elif [ -e /dev/loop0p2 ]; then
    sudo mount /dev/loop0p2 /media/cdrom
elif [ -e /dev/loop0p3 ]; then
    sudo mount /dev/loop0p3 /media/cdrom
else
    sudo mount /dev/loop0 /media/cdrom
fi

sudo mount -o loop tmp/ubuntu-2404-ecrviewer.raw /media/cdrom
mkisofs -f -iso-level=1 -J -r -T -pad -v -o image.iso /media/cdrom

# Clean up
sudo umount /media/cdrom
sudo losetup -d /dev/loop0










sudo losetup -f ubuntu-2404-ecrViewer.raw

sudo dd if=/dev/loop0 of=ubuntu-image.iso status=progress