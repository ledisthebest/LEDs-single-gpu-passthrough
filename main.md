---
translationKey: vfio-single
title: "单显卡直通教程"
date: 2022-02-15T00:00:00-07:00
# weight: 1
# aliases: ["/first"]
tags: ["cn", "linux", "arch", "VFIO", "KVM", "虚拟化"]
author: "ledisthebest"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: true
draft: true
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

---

## 更新日期：2022年02月23日

- 增加了图片
- 更改配置
- 文档更新

---

## 教程使用的电脑配置
- 处理器: AMD 锐龙 5800x 8核
- 显卡: 微星 GeForce RTX 3070 GAMING X TRIO 8G
- 主版：玩家国度 ROG Strix B550-A GAMING White 吹雪
- 内存: 16GB 3600Mhz 双通道
- 系统: Arch Linux 5.16
- 桌面环境: KDE Plasma 5.23 X11

## ！！要求！！
- 一个四核或更多的AMD64或英特尔x86-64处理器，支持硬件虚拟化。
- 8GB双通道内存或者更多， 不然不够分给客户机。
- 64GB固态盘空间或更多（macOS至少需要64GB，不然不允许安装）。
- 一块独立显卡，至少支持DirectX 11
- 核显/集显不建议，成功率较低，而且直通和不直通比没有太大的性能差异，如果想尝试参见[Intel GVT-g](https://wiki.archlinux.org/title/Intel_GVT-g)。
- 大部分在Big Navi之前的AMD显卡有重置Reset Bug, 可使用[vendor-reset](https://github.com/gnif/vendor-reset)修复。
- 若想使用macOS客户机，请使用AMD显卡（英伟达支持就是个笑话），及英特尔处理器（AMD处理器没有苹果官方支持，会有bug）。
- 发行版不一定要用Arch系的，不过不同发行版个别命令可能会不太一样，建议使用一个较新的发行版，不然内核的KVM会太低。

---

## 步骤
1. [配置一个简单的KVM](#配置一个简单的KVM)
2. [Libvirt 钩子](../VFIO/Libvirt%20Hooks%20cn.md)
3. [QEMU和Libvirt的配置](../VFIO/Configure%20Libvirt%20cn.md)
4. [显卡直通](../VFIO/Setting%20up%20Passthrough%20cn.md)
5. [some other things](../VFIO/Debugging%20and%20other%20features.md)

---

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






* * *
**其它资源**
- Arch Wiki [PCI passthrough](https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF) 
- GitLab [RisingPrismTV's script](https://gitlab.com/risingprismtv/single-gpu-passthrough)
