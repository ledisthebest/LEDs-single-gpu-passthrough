# 配置一个简单的KVM

**启用IOMMU**<br>
比如Systemd启动器：<br>
`nano /boot/loader/entries/arch.conf`<br>
把 `amd_iommu=on iommu=pt` 添加到options后面<br>
保存，重启系统

**检查IOMMU是否已启用**<br>
`sudo dmesg | grep -e DMAR -e IOMMU`<br>
找找有没有amd_IOMMU:Detected"

**检查IOMMU组是否有效**<br>
[iommuamd.sh](../resources/iommuamd.sh)
运行这个脚本，看看显卡是不是在自己的一个组里面。
```
IOMMU group 16
0a:00.0 VGA compatible controller \[0300\]: Advanced Micro Devices, Inc. \[AMD/ATI\] Baffin \[Radeon RX 550 640SP / RX 560/560X\] \[1002:67ff\] (rev cf)
Driver: amdgpu
0a:00.1 Audio device \[0403\]: Advanced Micro Devices, Inc. \[AMD/ATI\] Baffin HDMI/DP Audio \[Radeon RX 550 640SP / RX 560/560X\] \[1002:aae0\]
Driver: snd\_hda\_intel

```
复制一下，先保存下来。

**添加VFIO到内核模块**<br>
`sudo nano /etc/modprobe.d/vfio.conf`<br>
在vfio.conf里面添加<br>
```
options vfio-pci ids=1002:67ff,1002:aae0
options vfio-pci disable_idle_d3=1
options vfio-pci disable_vga=1
```
*ids=后面应该是刚才查看的显卡的那些id,每个值之间用`,`隔开*


**安装需要的软件<br>
`sudo pacman -S qemu libvirt edk2-ovmf virt-manager dnsmasq ebtables iptables bridge-utils`

**开机启用服务**<br>
```
sudo systemctl enable libvirtd
sudo systemctl enable virtlogd.socket
```

**开始Libvirt**<br>
```
"sudo systemctl start libvirtd"
`sudo systemctl start virtlogd.socket
```

**启用虚拟网络**<br>
```
sudo virsh net-start default
sudo virsh net-autostart default
```

**先打开Virt-Manager安装一个没有直通的虚拟机，然后去下一步**

[教程主页](../README-cn.md)