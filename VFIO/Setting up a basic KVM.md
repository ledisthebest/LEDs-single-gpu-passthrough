# Setting up a Basic KVM

**Enable IOMMU in Bootloader**<br>
`nano /boot/loader/entries/arch.conf`
add `amd_iommu=on iommu=pt` to the end of the options
Save and Reboot

**check IOMMU**<br>
`sudo dmesg | grep -e DMAR -e IOMMU`
look for amd_IOMMU:Detected"

**check PCI iommu groups**<br>
[iommuamd.sh](../_resources/5276daf6236346479e15f96ce0afe812.sh)
run this script, look for your GPU, make sure they are in their own group
```
IOMMU group 16
0a:00.0 VGA compatible controller \[0300\]: Advanced Micro Devices, Inc. \[AMD/ATI\] Baffin \[Radeon RX 550 640SP / RX 560/560X\] \[1002:67ff\] (rev cf)
Driver: amdgpu
0a:00.1 Audio device \[0403\]: Advanced Micro Devices, Inc. \[AMD/ATI\] Baffin HDMI/DP Audio \[Radeon RX 550 640SP / RX 560/560X\] \[1002:aae0\]
Driver: snd\_hda\_intel

```
copy it and save it somewhere. 


**Install required packages**<br>
`sudo pacman -S qemu libvirt edk2-ovmf virt-manager dnsmasq ebtables iptables bridge-utils`

**Enable them in init system**<br>
```
sudo systemctl enable libvirtd
sudo systemctl enable virtlogd.socket
```

**Start services**<br>
```
"sudo systemctl start libvirtd"
`sudo systemctl start virtlogd.socket
```

**enable virtual network**<br>
```
sudo virsh net-start default
sudo virsh net-autostart default
```

**open virt-manager and setting up an basic virtual machine without passthrough**
