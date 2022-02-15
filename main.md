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

## 步骤
1. [配置一个简单的KVM（非直通）](VFIO/Setting%20up%20a%20basic%20KVM%20cn.md)
2. [Libvirt 钩子](VFIO/Libvirt%20Hooks%20cn.md)
3. [QEMU和Libvirt的配置](VFIO/Configure%20Libvirt%20cn.md)
4. [显卡直通](VFIO/Setting%20up%20Passthrough%20cn.md)
5. [some other things](VFIO/Debugging%20and%20other%20features.md)

* * *
**其它资源**
- Arch Wiki [PCI passthrough](https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF) 
- GitLab [RisingPrismTV's script](https://gitlab.com/risingprismtv/single-gpu-passthrough)
