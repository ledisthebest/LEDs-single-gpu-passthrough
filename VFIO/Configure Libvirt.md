# Configuring Libvirt

edit libvirt.conf:<br>
`sudo nano /etc/libvirt/libvirtd.conf`

uncomment these two lines by removing the `#` in front of them:
```
unix_sock_group = "libvirt"
unix_sock_rw_perms = "0770"
```

add these two lines to the end of the file for logs:
```
log_filters="1:qemu"
log_outputs="1:file:/var/log/libvirt/libvirtd.log"
```
* * *
edit qemu.conf:

change `#user = "root"` to `user = "yourusername"`
change `#group = "root"` to `group = "libvirt"`

add yourself to the libvirt group:<br>
`sudo usermod -a -G libvirt yourusername`
* * *

**Restart computer or restart libvirt:**
```
sudo systemctl restart libvirtd.service
sudo systemctl restart virtlogd.socket
```
