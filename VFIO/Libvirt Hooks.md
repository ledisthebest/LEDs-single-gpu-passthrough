# Setup libvirt hooks
```
sudo mkdir /etc/libvirt/hooks
sudo nano /etc/libvirt/hooks/qemu
```

in qemu:
```
#!/bin/bash

OBJECT="$1"
OPERATION="$2"

if [[ $OBJECT == "win10" ]]; then
	case "$OPERATION" in
        	"prepare")
                systemctl start libvirt-nosleep@"$OBJECT"  2>&1 | tee -a /var/log/libvirt/custom_hooks.log
                /bin/vfio-startup.sh 2>&1 | tee -a /var/log/libvirt/custom_hooks.log
                ;;

            "release")
                systemctl stop libvirt-nosleep@"$OBJECT"  2>&1 | tee -a /var/log/libvirt/custom_hooks.log  
                /bin/vfio-teardown.sh 2>&1 | tee -a /var/log/libvirt/custom_hooks.log
                ;;
	esac
fi
```
then make it executable:<br>
`sudo chmod +x /etc/libvirt/hooks/qemu`

* * *
**edit start up script:**<br>
`sudo nano /etc/libvirt/hooks/vfio-startup.sh`

in vfio-startup.sh:
```
#!/bin/bash
# Helpful to read output when debugging
set -x

long_delay=10
medium_delay=5
short_delay=1
echo "Beginning of startup!"

function stop_display_manager_if_running {
    # Stop dm using systemd
    if command -v systemctl; then
        if systemctl is-active --quiet "$1.service" ; then
            echo $1 >> /tmp/vfio-store-display-manager
            systemctl stop "$1.service"
        fi

        while systemctl is-active --quiet "$1.service" ; do
            sleep "${medium_delay}"
        done

        return
    fi

    # Stop dm using runit
    if command -v sv; then
        if sv status $1 ; then
            echo $1 >> /tmp/vfio-store-display-manager
            sv stop $1
        fi
    fi
}


# Stop currently running display manager
if test -e "/tmp/vfio-store-display-manager" ; then
    rm -f /tmp/vfio-store-display-manager
fi

stop_display_manager_if_running sddm
stop_display_manager_if_running gdm
stop_display_manager_if_running lightdm
stop_display_manager_if_running lxdm
stop_display_manager_if_running xdm
stop_display_manager_if_running mdm
stop_display_manager_if_running display-manager

sleep "${medium_delay}"

# Unbind VTconsoles if currently bound (adapted from https://www.kernel.org/doc/Documentation/fb/fbcon.txt)
if test -e "/tmp/vfio-bound-consoles" ; then
    rm -f /tmp/vfio-bound-consoles
fi
for (( i = 0; i < 16; i++))
do
  if test -x /sys/class/vtconsole/vtcon${i}; then
      if [ `cat /sys/class/vtconsole/vtcon${i}/name | grep -c "frame buffer"` \
           = 1 ]; then
	       echo 0 > /sys/class/vtconsole/vtcon${i}/bind
           echo "Unbinding console ${i}"
           echo $i >> /tmp/vfio-bound-consoles
      fi
  fi
done

# Unbind EFI-Framebuffer
if test -e "/tmp/vfio-is-nvidia" ; then
    rm -f /tmp/vfio-is-nvidia
fi

if lsmod | grep "nvidia" &> /dev/null ; then
    echo "true" >> /tmp/vfio-is-nvidia
    echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind
fi

echo "End of startup!"
```
make it executable:<br>
```sudo chmod +x /etc/libvirt/hooks/vfio-startup.sh```

soft link it to /bin:<br>
`sudo ln -s /etc/libvirt/hooks/vfio-startup.sh /bin/vfio-startup.sh`

* * *
**edit tear down script:**<br>
`sudo nano /etc/libvirt/hooks/vfio-teardown.sh`

in vfio-teardown.sh:
```
#!/bin/bash
set -x

echo "Beginning of teardown!"

sleep 10

# Restart Display Manager
input="/tmp/vfio-store-display-manager"
while read displayManager; do
  if command -v systemctl; then
    systemctl start "$displayManager.service"
  else
    if command -v sv; then
      sv start $displayManager
    fi
  fi
done < "$input"

# Rebind VT consoles (adapted from https://www.kernel.org/doc/Documentation/fb/fbcon.txt)
input="/tmp/vfio-bound-consoles"
while read consoleNumber; do
  if test -x /sys/class/vtconsole/vtcon${consoleNumber}; then
      if [ `cat /sys/class/vtconsole/vtcon${consoleNumber}/name | grep -c "frame buffer"` \
           = 1 ]; then
    echo "Rebinding console ${consoleNumber}"
	  echo 1 > /sys/class/vtconsole/vtcon${consoleNumber}/bind
      fi
  fi
done < "$input"

# Rebind framebuffer for nvidia
if test -e "/tmp/vfio-is-nvidia" ; then
  echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind
fi

echo "End of teardown!"
```
make it executable:
`sudo chmod +x /etc/libvirt/hooks/vfio-teardown.sh`

soft link it to /bin:
`sudo ln -s /etc/libvirt/hooks/vfio-teardown.sh /bin/vfio-teardown.sh`

* * *
**edit libvirt no sleep service**<br>
`sudo nano /etc/systemd/system/libvirt-nosleep@.service`

in libvirt-nosleep@.service:
```
[Unit]
Description=Preventing sleep while libvirt domain "%i" is running

[Service]
Type=simple
ExecStart=/usr/bin/systemd-inhibit --what=sleep --why="Libvirt domain \"%i\" is running" --who=%U --mode=block sleep infinity
```
change permission:<br>
`sudo chmod 644 -R /etc/systemd/system/libvirt-nosleep@.service`

change ownership:<br>
`sudo chown root:root /etc/systemd/system/libvirt-nosleep@.service`
