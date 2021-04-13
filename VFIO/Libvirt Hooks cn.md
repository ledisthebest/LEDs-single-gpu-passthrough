# 配置Libvirt脚本
在Libirt里面创建一个hooks文件夹<br>
`sudo mkdir /etc/libvirt/hooks`

把[这里](../libvirt-hooks)的三个文件放到hooks文件夹里面

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