---
translationKey: vfio-single
title: "单显卡直通教程"
date: 2022-02-15T00:00:00-07:00
weight: 1
# aliases: ["/first"]
tags: ["cn", "linux", "arch", "VFIO", "KVM", "虚拟化"]
author: "ledisthebest"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: true
draft: false
hidemeta: false
comments: false
description: "传统艺能了"
canonicalURL: "https://liucreator.gitlab.io/zh/posts/0x0b-single-gpu-passthrough/readme-cn/"
disableHLJS: false # to disable highlightjs
disableShare: false
hideSummary: false
searchHidden: false
ShowReadingTime: false
ShowBreadCrumbs: true
ShowPostNavLinks: true
ShowCodeCopyButtons: true
cover:
    image: "cover/X" # image path/url
    alt: "<alt text>" # alt text
    caption: "<text>" # display caption under cover
    relative: false # when using page bundles set this to true
    hidden: false # only hide on current single page
editPost:
    URL: "https://gitlab.com/liucreator/liucreator.gitlab.io/-/blob/master/content"
    Text: "改进建议" # edit text
    appendFilePath: true # to append file path to Edit link
---

# 介绍
这是我的单显卡直通配置过程，我在多个不同配置的电脑上都试过，这个方法都成功了。

我这里讲的是AMD处理器（英特尔的也差不多，个别参数会不一样）; 系统是Arch Linux, 如果是其它发行版一些软件名和文件位置可能会不太一样。

可以配合视频教程操作，Bibibili/YouTube链接:
- [![Followers](https://bilistats.lonelyion.com/followers?uid=589560036)](https://space.bilibili.com/589560036/channel/seriesdetail?sid=2031728)
- [![YouTube Channel Subscribers](https://img.shields.io/youtube/channel/subscribers/UCKXFTVfYRA8Ho71bAT5tfVA?style=social)](https://www.youtube.com/channel/UCKXFTVfYRA8Ho71bAT5tfVA?sub_confirmation=1)

或者加入我们的QQ群：`689962825`
![QQ](/img/0x0B-single-gpu-passthrough/qq-group.png)

---

## 更新日期：2022年02月15日

- 增加了图片
- 更改配置
- 文档更新

---

## 电脑配置
- 处理器: AMD 锐龙 5800x 8核
- 显卡: 微星 GeForce RTX 3070 GAMING X TRIO 8G
- 主版：玩家国度 ROG Strix B550-A GAMING 吹雪
- 内存: 16GB 3600Mhz 双通道
- 系统: Arch Linux 5.16
- 桌面环境: KDE Plasma 5.23 X11

---

## 步骤
1. [配置一个简单的KVM](#配置一个简单的KVM)
2. [Libvirt 钩子](../VFIO/Libvirt%20Hooks%20cn.md)
3. [QEMU和Libvirt的配置](../VFIO/Configure%20Libvirt%20cn.md)
4. [显卡直通](../VFIO/Setting%20up%20Passthrough%20cn.md)
5. [some other things](../VFIO/Debugging%20and%20other%20features.md)

---

# 配置一个简单的KVM

## 启用IOMMU
1. 重启进入UEFI/BIOS固件设置，开启IOMMU和虚拟化。通常在CPU高级选项里面，AMD处理器的一般叫Virtualization Technology或AMD-Vi，英特尔的叫VT-x或VT-d。
2. 添加下列内核参数到启动器，[详情戳这里](https://wiki.archlinux.org/title/Kernel_parameters_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))，保存然后重启。
    - AMD处理器(根据BIOS设置默认已启用？)：`amd_iommu=on`
    - 英特尔处理器：`intel_iommu=on`
    - 可视情况添加（修复或导致黑屏）：`iommu=pt`

[![kernel-parameters.jpg](/img/0x0B-single-gpu-passthrough/kernel-parameters.jpg "在GRUB里面添加内核参数")](/img/0x0B-single-gpu-passthrough/kernel-parameters.jpg)

3. 重启后，看看启动日志检查一下IOMMU是否已启用，使用超级用户权限运行 
```
dmesg | grep -e DMAR -e IOMMU
```
找找有没有 `amd_IOMMU:Detected` 或者 `Intel-IOMMU: enabled` 类似的信息。

[![iommu-on.jpg](/img/0x0B-single-gpu-passthrough/iommu-on.jpg "IOMMU已启用")](/img/0x0B-single-gpu-passthrough/iommu-on.jpg)

---

## 检查IOMMU组是否有效
用超级用户运行这串代码（来自[Arch Wiki](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Ensuring_that_the_groups_are_valid)），**或者** 可以运行[这个脚本](/files/0x0B-single-gpu-passthrough/iommu.sh)（更好看一点）

**小贴士：不要随便运行那些你不懂的代码!**

```
shopt -s nullglob
for g in `find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V`; do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done;
```

，
看看显卡是不是在自己的一个组里面。

[![iommu-groups.jpg](/img/0x0B-single-gpu-passthrough/iommu-groups.jpg "我的IOMMU组")](/img/0x0B-single-gpu-passthrough/iommu-groups.jpg)

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






* * *
**其它资源**
- Arch Wiki [PCI passthrough](https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF) 
- GitLab [RisingPrismTV's script](https://gitlab.com/risingprismtv/single-gpu-passthrough)
