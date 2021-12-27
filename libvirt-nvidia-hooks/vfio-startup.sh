set -x

systemctl stop your-display-manager

echo 0 > /etc/class/vtconsole/vtcon0/bind
echo 0 > /etc/class/vtconsole/vtcon1/bind

echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

sleep 15

modprobe -r nvidia_drm
modprobe -r nvidia_uvm
modprobe -r nvidia_modeset
modprobe -r drm_kms_helper
modprobe -r nvidia
modprobe -r i2c_nvidia_gpu
modprobe -r drm

virsh nodedev-detach pci_0000_AB_CD_E

modprobe vfio_pci
modprobe vfio
modprobe vfio_iommu_type1
modprobe vfio_virqfd