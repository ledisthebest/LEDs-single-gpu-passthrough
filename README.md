# Single GPU Passthrough on Ryzen CPU

https://liucreator.gitlab.io/zh/posts/0x0b-single-gpu-passthrough/main/

[中文版本](README-cn.md)<br>
These are my steps to set up QEMU/KVM with GPU passthrough as of 2021 March, 
it works for me as I tried many times on different systems.

You might need to change a few things, and feel free to ask me if you have any questions!

My current setup is on Ryzen CPU with Radeon GPU, and sorry my English is not the best.

- [![Followers](https://bilistats.lonelyion.com/followers?uid=589560036)](https://space.bilibili.com/589560036/channel/seriesdetail?sid=2031728)
- [![YouTube Channel Subscribers](https://img.shields.io/youtube/channel/subscribers/UCKXFTVfYRA8Ho71bAT5tfVA?style=social)](https://www.youtube.com/channel/UCKXFTVfYRA8Ho71bAT5tfVA?sub_confirmation=1)

**My Specs:**
- CPU: AMD Ryzen 3900x 12 cores
- GPU: MSI Radeon RX 560 4GT LP OC
- RAM: 32GB 3200Mhz dual channels
- OS: Arch Linux 5.11
- DE: KDE Plasma 5.21


* * *
**Procedure:**
1. [Setting up an basic KVM on linux without VFIO](/VFIO/Setting%20up%20a%20basic%20KVM.md)
2. [Libvirt Hooks and Scripts](/VFIO/Libvirt%20Hooks.md)
3. [QEMU+Libvirt Configuration](/VFIO/Configure%20Libvirt.md)
4. [GPU passthrough](/VFIO/Setting%20up%20Passthrough.md)
5. [some other things](/VFIO/Debugging%20and%20other%20features.md)

* * *

---

Please considering of supporting me if you find my guides or videos helpful!

[![Paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/donate/?hosted_button_id=A47HPSXTPD5HE)

---

**Credits:**
- Arch Wiki [PCI passthrough](https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF) 
- GitLab [RisingPrismTV's script](https://gitlab.com/risingprismtv/single-gpu-passthrough)
- SubReddit [r/VFIO](https://www.reddit.com/r/VFIO/)
