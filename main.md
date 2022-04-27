---
translationKey: vfio-single
title: "单显卡直通教程"
date: 2022-02-15T09:00:00-07:00
weight: 1
# aliases: ["/first"]
tags: ["cn", "linux", "arch", "VFIO", "KVM", "虚拟化"]
author: "ledisthebest"
# author: ["Me", "You"] # multiple authors
showToc: true
TocOpen: true
draft: false
hidemeta: false
comments: true
description: "传统艺能了"
canonicalURL: "https://liucreator.gitlab.io/zh/posts/0x0b-single-gpu-passthrough/main/"
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
    URL: "https://gitlab.com/liucreator/LEDs-single-gpu-passthrough/-/blob/cn/main.md"
    Text: "改进建议" # edit text
    appendFilePath: false # to append file path to Edit link
---

# 介绍
这是我的单显卡直通配置过程，我在多个不同配置的电脑上都试过，这个方法都成功了。

我这里讲的是AMD处理器（英特尔的也差不多，个别参数会不一样）; 系统是Arch Linux, 如果是其它发行版一些软件名和文件位置可能会不太一样。

可以配合视频教程操作，Bibibili/YouTube链接:
- [![Followers](https://bilistats.lonelyion.com/followers?uid=589560036)](https://space.bilibili.com/589560036/channel/seriesdetail?sid=2031728)
- [![YouTube Channel Subscribers](https://img.shields.io/youtube/channel/subscribers/UCKXFTVfYRA8Ho71bAT5tfVA?style=social)](https://www.youtube.com/channel/UCKXFTVfYRA8Ho71bAT5tfVA?sub_confirmation=1)

或者加入我们的QQ群：`689962825`

还在编辑中，如果能力，[请帮我完善、修订、添加更多内容](https://gitlab.com/liucreator/LEDs-single-gpu-passthrough/-/blob/cn/main.md)！

本人是一名半工半读的学生，如果你觉得我的视频和教程有用，请考虑支持我！
可以通过[Paypal](https://www.paypal.com/donate/?hosted_button_id=HVU7NRQMZGMNN)给我捐赠：

{{< embedhtml>}}
<form action="https://www.paypal.com/donate" method="post" target="_top">
<input type="hidden" name="hosted_button_id" value="HVU7NRQMZGMNN" />
<input type="image" src="https://www.paypalobjects.com/zh_XC/i/btn/btn_donateCC_LG.gif" border="0" name="submit" title="PayPal - The safer, easier way to pay online!" alt="使用PayPal按钮进行捐赠" />
<img alt="" border="0" src="https://www.paypal.com/zh_C2/i/scr/pixel.gif" width="1" height="1" />
</form>

{{< /embedhtml>}}

或者选择在[微信](/img/wechatpay.jpg)上给我打赏（标注VFIO），非常感谢！


---

## 更新日期：2022年04月26日

- 文档更新
- 开启评论区

---

## 电脑配置
- 处理器: AMD 锐龙 5800x 8核
- 显卡: 微星 GeForce RTX 3070 GAMING X TRIO 8G
- 主版：玩家国度 ROG Strix B550-A GAMING White 吹雪
- 内存: 16GB 3600Mhz 双通道
- 系统: Arch Linux 5.16
- 桌面环境: KDE Plasma 5.23 X11

---

## ！！要求！！
- 一个四核或更多的AMD64或英特尔x86-64处理器，支持硬件虚拟化。
- 8GB双通道内存或者更多， 不然不够分给客户机。
- 64GB固态盘空间或更多（macOS至少需要64GB，不然不允许安装）。
- 一块独立显卡，至少支持DirectX 11
- 核显/集显不建议，成功率较低，而且直通和不直通比没有太大的性能差异，如果想尝试参见[Intel GVT-g](https://wiki.archlinux.org/title/Intel_GVT-g)。
- 大部分在Big Navi之前的AMD显卡有重置Reset Bug, 可使用[vendor-reset](https://github.com/gnif/vendor-reset)修复。
- 若想使用macOS客户机，请使用AMD显卡（英伟达支持就是个笑话），及英特尔处理器（AMD处理器没有苹果官方支持，会有bug）。
- 发行版不一定要用Arch系的，不过不同发行版个别命令可能会不太一样，建议使用一个较新的发行版，不然内核的KVM会太低。
- 笔记本不建议，硬件较为封闭，跟常规桌面端不太一样。

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

![](/img/0x0B-single-gpu-passthrough/kernel-parameters.png "在GRUB里面添加内核参数")

3. 重启后，看看启动日志检查一下IOMMU是否已启用，使用超级用户权限运行 
```
dmesg | grep -e DMAR -e IOMMU
```
找找有没有 `amd_IOMMU:Detected` 或者 `Intel-IOMMU: enabled` 类似的信息。

![](/img/0x0B-single-gpu-passthrough/iommu-on.png "IOMMU已启用")

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

![](/img/0x0B-single-gpu-passthrough/iommu-groups.png "我的IOMMU组")

```
IOMMU group 16
0a:00.0 VGA compatible controller [0300]: Advanced Micro Devices, Inc. [AMD/ATI] Baffin [Radeon RX 550 640SP / RX 560/560X] [1002:67ff] (rev cf)
Driver: amdgpu
0a:00.1 Audio device [0403]: Advanced Micro Devices, Inc. [AMD/ATI] Baffin HDMI/DP Audio [Radeon RX 550 640SP / RX 560/560X] [1002:aae0]
Driver: snd_hda_intel

```
复制一下，先保存下来。

---

## 添加VFIO到内核模块

新建并打开`/etc/modprobe.d/vfio.conf`，在里面添加：
```
options vfio-pci ids=1002:67ff,1002:aae0
options vfio-pci disable_idle_d3=1
options vfio-pci disable_vga=1
```
*ids=后面应该是刚才查看的显卡的那些id,每个值之间用`,`隔开*

![](/img/0x0B-single-gpu-passthrough/vfio-conf.png "编辑vfio.conf")

---

## 安装需要的组件
如果是Arch系（除了Artix），安装下列包
```
qemu libvirt edk2-ovmf virt-manager dnsmasq ebtables iptables bridge-utils gnu-netcat
```
**安装`iptables`和`ebtables`会询问是否要替换掉`iptables-nft`，`y`确定，因为目前QEMU尚未更新，还依赖于老的那些网络组件。**

---

## 启用服务

### 启动Libvirtd：（Systemd）
```
systemctl start libvirtd
```

#### 设为开机自启：
```
systemctl enable libvirtd
```

### 启动默认虚拟网络（NAT）
```
virsh net-start default
```

#### 设为开机自启：
```
virsh net-autostart default
```

现在可以打开虚拟机管理器，安装一个非直通的虚拟机了。

---

# 安装一个非直通的虚拟机

*这里讲的是Windows 10，是个好的开始，建议弄完这个成功后再去尝试Windows 11或者macOS。*

## 下载镜像
- Windows 10的正版镜像可以直接从[微软官网](https://www.microsoft.com/zh-cn/software-download/windows10ISO)下载，不过还是需要购买激活码。
- （可选）为了提高性能，可以从[红帽网站](https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md)下载安装Virtio Windows驱动，支持Windows XP至Windows 11。（Linux客户机不需要，已经自带）

将它们保存找的到的地方，最好放在`/Home`里面。

---

## 创建虚拟机
1. QEMU/KVM -> 新建虚拟机 -> 本地安装介质，下一步
2. 浏览并选择已下载的Windows 10安装镜像，下一步
3. 客户机内存怎么分配都行，最好给宿主机留1/4的内存（比如8GB分6GB留2GB，16GB分12GB留4GB），CPU数可以待会儿改，下一步
4. 默认为虚拟机启用存储（存储磁盘镜像建议放在`/Home`下面），下一步
5. 设置客户机名称，默认是`win10`，可以改，不过以后需要修改脚本，

    **！！选择在安装前自定义配置！！**

## 基本客户机配置
- 概况（**！！这个一定要现在设置好，不然以后就很难改了！！**）
    - 芯片组：`Q35`
    - 固件：`ovmf_code.fd`（不需要secboot和csm）

- CPU数
    - vCPU分配数，根据拓扑设置（套接字x核心x线程）
    - 配置： 一般选择`host-model`或者`host-passthrough`（`host-passthrough`有时候可能会导致AMD处理器性能损耗严重？）
    - 拓扑：
        - 套接字（翻译错误？），插槽：几个处理器，大部分人就1个
        - 核心：分配给客户机几个核心（正常一点，比如2核，4核，6核，8核等等），最少留给宿主机1/4的总核心数
        - 线程：每个分配的核心有几个线程（根据你实体的处理器来，如果有超线程就设2，没有设1）

- 引导选项
    - 选择`SATA CDROM 1`（Windows 10的安装镜像）

- SATA 磁盘 1（客户机的存储空间）
    - （可选，理论上提升磁盘性能%300）把`SATA`改成`VirtIO`

- NIC（客户机网络）
    - 网络源：`默认NAT`就行（可根据个人需求设置桥接网络，不要使用`macvtap`
    - 设备型号：可以改成VirtIO提高性能（需要安装VirtIO驱动）
    - IP地址：第一次启动后会自动生成

然后选择 添加硬件 -> 存储 -> 选择或添加自定义存储，浏览并添加已下载的Virtio win驱动镜像，设备类型改成`CDROM设备`

最后检查一下，开机安装Windows就行了！

---


**其它资源**
- Arch Wiki [PCI passthrough](https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF) 
- GitLab [RisingPrismTV's script](https://gitlab.com/risingprismtv/single-gpu-passthrough)
