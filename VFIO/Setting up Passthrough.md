# Setting up passthrough

**dump GPU VBIOS:**
- easiest way: use GPU-Z on a temporary windows 10
- or download it from [tech power up vga bios collection](https://www.techpowerup.com/vgabios/)
- dump in linux using [NVIDIA](https://www.techpowerup.com/download/nvidia-nvflash/) or [AMD](https://www.techpowerup.com/download/ati-atiflash/)
- or by command line

**patch VBIOS - NVIDIA only**
1. open the rom with a hex editor (I use Okteta or Bless)
2. look for CHAR "video"
	Remove everything before `U.`(55 in hex).
4. save it somewhere
	*home directory works for Arch Linux*
	Arch/Fedora: `sudo mkdir /var/lib/libvirt/vbios`
	Ubuntu/OpenSUSE/Mint(Distros with AppArmour): `sudo mkdir /usr/share/vgabios`

5. add read and execute permission
`sudo chmod -R 660 patched.rom`
6. own it
`sudo chown yourusername:users patched.rom`

**configure VM**
1. go to virt-manager and add all pcie part of the graphic card to vm
2. enable XML editing, in pci device, after `</source>` add: 
	`<rom bar="on" file="/path/to/patched.rom"/>`
3. remove things like channel spice, tablet, usb redirection, video QXL etc.
4. add usb devices like mouse, keyboard, usb headsets

**Bypass Nvidia VM detection(not required anymore as of April 2021?)**
Edit XML:
- add the following before `</hyperv>`, value should be 8 to 12 characters:
	`<vendor_id state='on' value='randomid'/>`
	AMD gpu can use id "`AuthenticAMD`".

- inside of `<features>` and `</features>` add:
	```
	<kvm>
    	<hidden state='on'/>
  	</kvm>
	```
