# 直通显卡

**导出你的显卡的VGA BIOS**
- 最简单的办法: 如果电脑是Windows双系统，可以用[GPU-Z](https://www.techpowerup.com/gpuz/)
- 去[Tech Power Up](https://www.techpowerup.com/vgabios/)下载一个
- 在Linux上使用[NVIDIA](https://www.techpowerup.com/download/nvidia-nvflash/) or [AMD](https://www.techpowerup.com/download/ati-atiflash/)
- 其它命令行方法[Arch Wiki](https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF#UEFI_(OVMF)_compatibility_in_VBIOS)

**VBIOS补丁- 只有英伟达显卡需要**
1. 用十六进制编辑器打开导出的rom(我个人喜欢Bless)
2. 查找字符"VIDEO"<br>
	把`VIDEO`前面第一个大写`U.`(十六进制是55)之前的所有的headers都删掉.
4. 保存到某个地方<br>
	*我在Arch上保存到个人主目录文件夹是没问题的*<br>
	Arch、Fedora可以保存到`/var/lib/libvirt/vbios`里面，<br>
	Ubuntu/OpenSUSE/Mint(用AppArmour的发行版)可以保存到`/usr/share/vgabios`里面。
5. 修改权限：<br>
`sudo chmod -R 660 vbios文件.rom`
6. 更改拥有者
`sudo chown 你的用户名:users vbios文件.rom`

*	*	*

**配置qemu虚拟机**
1. 打开虚拟机管理器，把显卡的所有pci部分都添加到虚拟机里面。
2. 启用XML编辑, 在显卡的所有pci设备里面, 在`</source>`之后添加:<br>
	`<rom bar="on" file="/path/to/patched.rom"/>`
3. 把信道，usb转接，显卡qxl,触摸板那些东西删掉
4. 添加你的USB设备，比如鼠标、键盘和USB耳机。

**绕过英伟达Geforce显卡防虚拟化检测（恶名昭著的错误43）**<br>
*2021四月之后好像不需要了*<br>
编辑XML:
- 在`</hyperv>`之前添加（value应该等于8-12个字母）:<br>
	`<vendor_id state='on' value='randomid'/>`<br>
	AMD显卡可以用"`AuthenticAMD`"作为id但不需要，因为AMD不会拦着你显卡虚拟化。

- 在`<features>` 和 `</features>` 之间添加:
	```
	<kvm>
    	<hidden state='on'/>
  	</kvm>
	```
那么现在试试你的虚拟机吧！第一次开机可能会有点慢，因为要装显卡驱动，不过等等就可以了。

[教程主页](../README-cn.md)