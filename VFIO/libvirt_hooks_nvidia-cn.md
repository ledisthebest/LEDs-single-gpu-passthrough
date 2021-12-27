# 配置Libvirt脚本（针对宿主机在使用闭源驱动的英伟达显卡）
[AMD显卡请看这里](Libvirt%20Hooks%20cn.md)

在Libirt里面创建一个hooks文件夹<br>
`sudo mkdir /etc/libvirt/hooks`

把[这里](../libvirt-nvidia-hooks)的三个文件放到hooks文件夹里面

记得之前保存的这个吗？（我这拿AMD显卡举例子）
```
IOMMU group 16
0a:00.0 VGA compatible controller \[0300\]: Advanced Micro Devices, Inc. \[AMD/ATI\] Baffin \[Radeon RX 550 640SP / RX 560/560X\] \[1002:67ff\] (rev cf)
Driver: amdgpu
0a:00.1 Audio device \[0403\]: Advanced Micro Devices, Inc. \[AMD/ATI\] Baffin HDMI/DP Audio \[Radeon RX 550 640SP / RX 560/560X\] \[1002:aae0\]
Driver: snd\_hda\_intel

```

看到前面的`0a:00.0`和`0a:00.1`吗？把它看成`AB:CD.E`.
打开**vfio-startup.sh**和**vfio-teardown.sh**,
把里面的`pci_0000_AB_CD_E`按字母替换了，你的显卡有几个部分，就需要几行。

然后要根据你的显示管理器，把`your-display-manager` 改成你的显示管理器的服务，我用的是SDDM
不知道的可以尝试用`file /etc/systemd/system/display-manager.service` 命令查看。

比如这是我的**vfio-startup.sh**，从：
```
...
systemctl stop your-display-manager
...
virsh nodedev-detach pci_0000_AB_CD_E
...
```

改成了：
```
...
systemctl stop sddm
...
virsh nodedev-detach pci_0000_0a_00_0
virsh nodedev-detach pci_0000_0a_00_1
...
```


别忘了也要改**vfio-teardown.sh**!

---

都变成可执行的文件<br>
`sudo chmod +x /etc/libvirt/hooks/*`<br>

把两个脚本软链接到根目录的bin文件夹
```
sudo ln -s /etc/libvirt/hooks/vfio-startup.sh /bin/vfio-startup.sh
sudo ln -s /etc/libvirt/hooks/vfio-teardown.sh /bin/vfio-teardown.sh
```

* * *
**防止Libvirt在运行时休眠**<br>
`sudo nano /etc/systemd/system/libvirt-nosleep@.service`

在libvirt-nosleep@.service里面添加：
```
[Unit]
Description=Preventing sleep while libvirt domain "%i" is running

[Service]
Type=simple
ExecStart=/usr/bin/systemd-inhibit --what=sleep --why="Libvirt domain \"%i\" is running" --who=%U --mode=block sleep infinity
```
更改权限：<br>
`sudo chmod 644 -R /etc/systemd/system/libvirt-nosleep@.service`<br>

变成系统文件<br>
`sudo chown root:root /etc/systemd/system/libvirt-nosleep@.service`

[教程主页](../README-cn.md)