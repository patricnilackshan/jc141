### Setup Guide - SteamDeck - SteamOS

You can stay on your SteamOS system, even though it's not a good choice for the freedom of the community from corporations.

The following commands are needed

```
passwd
```
You can now use sudo because you have a password for it.

```
sudo steamos-readonly disable
```

You can now go back to the main guide.

After finishing it, you should get sc-controller to use SteamDeck inputs without needing to run through Steam.
(You can get it from other sources, doesn't matter)

```
sudo pacman -S rumpowered/sc-controller
```

<br><br>

Or you can get your hands clean and use a normal arch distro.

### Setup Guide - SteamDeck - Arch


#### Install any Arch distro. We recommend EndeavourOS.


1. Create a bootable USB drive with the distro iso. - [Guide](https://discovery.endeavouros.com/installation/create-install-media-usb-key/2021/03/)
2. Use a USB-C adapter to connect the drive to your deck.
3. Turn off your deck, hold 'Volume Down', and click the Power button. When you hear a sound, let go of the volume button.
4. Select the USB-EFI device.
5. Follow the installer's steps. Pick KDE Plasma if you want to deal with the fewest issues. (online install)
   - Gnome is also fine. Other DE's less likely to be.
   - You will need to rotate the screen position in the display settings.
6. Boot into the new system and run `sudo pacman -Syyu` then reboot again.
<br>


### Add required repos


```sh
echo '


[rumpowered]
SigLevel = Never
Server = https://jc141x.github.io/rumpowered-packages/$arch


[jupiter-staging]
Server = https://steamdeck-packages.steamos.cloud/archlinux-mirror/$repo/os/$arch
SigLevel = Never


[holo-staging]
Server = https://steamdeck-packages.steamos.cloud/archlinux-mirror/$repo/os/$arch
SigLevel = Never ' | sudo tee -a /etc/pacman.conf


sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf


sudo pacman -Syyu
```
<br>


### SteamDeck Hardware Drivers


```sh
sudo pacman -S jupiter-staging/linux-neptune jupiter-staging/linux-neptune-headers jupiter-staging/linux-firmware-neptune jupiter-staging/jupiter-hw-support rumpowered/sc-controller
```
 
Make new kernel default.


```sh
sudo grub-mkconfig -o /boot/grub/grub.cfg
```


Reboot and select the option with `linux neptune` using the arrow keys.
<br>


### Done

Please head back to the main setup page now and follow the instructions for Arch-based distros there.