# 配置Libvirt

**编辑libvirt.conf**<br>
`sudo nano /etc/libvirt/libvirtd.conf`

找到这两行，把前面的`#`删掉：
```
unix_sock_group = "libvirt"
unix_sock_rw_perms = "0770"
```
可以选择把这两行添加到文件的最后面（日志文件）:
```
log_filters="1:qemu"
log_outputs="1:file:/var/log/libvirt/libvirtd.log"
```
* * *
**编辑qemu.conf**<br>
`sudo nano /etc/libvirt/qemu.conf`<br>

把 `#user = "root"` 改成 `user = "yourusername"`,<br>
`#group = "root"` 改成 `group = "libvirt"`<br>

把自己添加到libvirt组里面：<br>
`sudo usermod -a -G libvirt 用户名`
* * *

**重启电脑或者重启libvirt**
```
sudo systemctl restart libvirtd.service
sudo systemctl restart virtlogd.socket
```

[教程主页](../README-cn.md)