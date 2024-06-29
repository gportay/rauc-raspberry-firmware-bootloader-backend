# raspberrypi-firmware-rauc-bootloader-backend

An implementation of a RAUC custom bootloader backend for the Raspberry Pi
firmware.

## DESCRIPTION

The Raspberry Pi firmware supports fail-safe OS updates with A/B booting thanks
to the optional configuration file [autoboot.txt] and the one-shot reboot flag
[tryboot].

Unlike the [U-Boot] and [Barebox] bootloader backends, the custom bootloader
backend for the Raspberry Pi firmware cannot implement a boot-attempts counter.
Its one-shot reboot flag is very similar to the EFI variable `BootNext` of the
[EFI] bootloader backend. It is like an implementation `boot-attempts` counter
of 1 after an update.

_Note_: The drawback is the firmware cannot fallback to the other system if the
primary system gets unbootable for some reason.

The Raspberry Pi firmware RAUC custom bootloader backend parses and updates the
file `autoboot.txt` in the first partition. It gets the one-shot reboot flag
set by the firmware to the device-tree blob node `/chosen/bootloader/partition`
at boot thanks to the utility `fdtget`, or it sets it down to the firmware for
the next boot thanks to the utility [vcmailbox].

It implements the four mandatory actions:
 - get the primary slot
 - set the primary slot
 - get the boot state
 - set the boot state

_Note_: The custom bootloader backend APIs for the Raspberry Pi firmware are
self-documented in the shell [backend] script.

## TRYBOOT

The online documentation for [tryboot] tells to set the one-shot flag in the
`reboot` command as below:

	# Quotes are important. Reboot only accepts a single argument.
	sudo reboot '0 tryboot'

The kernel of the [Raspberry Pi hardwares] forwards the optional [reboot]
argument given to [reboot(2)] to the [raspberrypi firmware driver] before the
system is restarted. The driver submits the mailbox tag to the VPU firmware
through the [mailbox property interface].

It is highly undesirable to trigger a `reboot` from within RAUC to set the new
boot state. The firmware utility [vcmailbox] submits from the userspace thanks
to the [broadcom vcio driver] instead.

_Note_: The tag **Set Reboot Flags** is not documented yet; The [commit] in the
kernel tree reveals it:

---
#### Set reboot flags

 * Tag: 0x00030064
 * Request:
   * Length: 4
   * Value:
     * u32: flags
 * Response:
   * Length: 0
   * Value:
---

## CONFIGURATION FILES

### SYSTEM.CONF

The RAUC file [system.conf] **MUST** set the attribute `bootloader` to `custom`
in the section `system`, and the attribute `bootloader-custom-backend` to the
location of the custom bootloader backend in the section `handlers`.

For example; if the backend is at `/usr/lib/rauc/backend/raspberrypi-firmware`:

	[system]                                                                        
	# (...)
	bootloader=custom                                                               
	
	[handlers]                                                                      
	# (...)
	bootloader-custom-backend=/usr/lib/rauc/backend/raspberrypi-firmware

Furthermore, the file **MUST** define the rootfs slots **AND** their firmware
slots in multiple sections `slot`; the firmware slots have to be bounded to the
rootfs slots using the attribute `parent` instead of having the attribute
`bootname` set.

For example; if the partition table is MBR, with the first partition containing
the [autoboot.txt] file, with the next two following partitions containing the
firmware files, and with the fourth and last partition is an extended partition
containings the two rootfs partitions:

	[slot.firmware.0]
	device=/dev/mmcblk0p2
	type=vfat
	parent=rootfs.0
	
	[slot.firmware.1]
	device=/dev/mmcblk0p3
	type=vfat
	parent=rootfs.1
	
	[slot.rootfs.0]
	device=/dev/mmcblk0p5
	type=ext4
	bootname=ROOTFS-A
	
	[slot.rootfs.1]
	device=/dev/mmcblk0p6
	type=ext4
	bootname=ROOTFS-B

### AUTOBOOT.TXT

The Raspberry Pi firmware file [autoboot.txt] **MUST** be located at path
`/boot/autoboot.txt`; i.e. the partition containing that file has to be mounted
to `/boot`.

For example; if booting from SD-card and using [fstab(5)]:

	# <device>      <mount point>  <type> <options> <dump>  <pass>
	/dev/mmcblk0p1  /boot          vfat   rw        0       0

### IMPORTANT

The firmware block devices **MUST** be coherent in both files [system.conf] and
[autoboot.txt]; i.e. the firmware partition numbers in `boot_partition` have to
match the ones defined in the slot sections.

For example; if the primary slot is `slot.rootfs.0`, and if the partition table
in the one defined in the [examples](#systemconf) above:

	[all]
	tryboot_a_b=1
	boot_partition=2
	[tryboot]
	boot_partition=3

## REQUIREMENTS

### BASH

The [Bourne Again shell] since the custom bootloader backend is a shell script
using several bashism (such as bash arrays, the compound command `[[`, or the
binary operator `=~`).

_Important_: The [backend] is written in pure [bash(1)].

### FDTGET

The device-tree compiler [fdtget] utility to read the bootloader values from
the device-tree.

### VCMAILBOX

The raspberrypi [vcmailbox] utility to set the one-shot reboot flag [tryboot].

### VCIO DRIVER

The downstream raspberrypi [broadcom vcio driver] to let the [vcmailbox]
utility to drive mailbox interface to VideoCore.

_Important_: The driver is not supported upstream.

## KERNEL UPDATES

The kernel updates through the installation of the firmware slots require an
installation [hook] in the bundle to include the appropriate kernel parameter
`root=` in the file `cmdline.txt`. More information are given in that [change].

_Note_: The kernel updates are doable using installation [handlers] in the root
filesystem.

## NATIVE BOOTCHOOSER IMPLEMENTATION

The native bootchooser implementation in the RAUC tree is on its way.

## INSTALL

Run the following command to install *bootloader-custom-backend(1)*,
*system-info(1)* and *rauc-mark-good.service(8)*

	$ sudo make install

Traditional variables *DESTDIR* and *PREFIX* can be overridden

	$ sudo make install PREFIX=/opt/raspberrypi-firmware-rauc-bootloader-backend

Or

	$ make install DESTDIR=$PWD/pkg PREFIX=/usr

## BUGS

Report bugs at *https://github.com/gportay/raspberrypi-firmware-rauc-bootloader-backend/issues*

## AUTHOR

Written by Gaël PORTAY *gael.portay@gmail.com*

## COPYRIGHT

Copyright (c) 2024 Gaël PORTAY

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free
Software Foundation, either version 2.1 of the License, or (at your option) any
later version.

[Barebox]: https://rauc.readthedocs.io/en/latest/integration.html#barebox
[Bourne Again shell]: https://www.gnu.org/software/bash/
[EFI]: https://rauc.readthedocs.io/en/latest/integration.html#efi
[Raspberry Pi hardwares]: https://www.raspberrypi.com/products/
[U-Boot]: https://rauc.readthedocs.io/en/latest/integration.html#id5
[autoboot.txt]: https://www.raspberrypi.com/documentation/computers/config_txt.html#autoboot-txt
[backend]: bootloader-custom-backend
[bash(1)]: https://linux.die.net/man/1/bash
[broadcom vcio driver]: https://github.com/raspberrypi/linux/blob/rpi-6.6.y/drivers/char/broadcom/vcio.c
[change]: https://github.com/Rtone/rtone-br2-external/commit/9ba8d9b3df9584e50cf5ae6952af54417a86b3f3
[commit]: https://github.com/raspberrypi/linux/commit/777a6a08bcf8f5f0a0086358dc66d8918a0e1c57#diff-1c6051b88ea21684666367f31afc5452e51abc9fe5f340281cd9d38459ac3d35R224-R225
[custom]: https://rauc.readthedocs.io/en/latest/integration.html#custom
[fdtget]: https://git.kernel.org/pub/scm/utils/dtc/dtc.git/tree/fdtget.c
[fstab(5)]: https://linux.die.net/man/5/fstab
[handlers]: https://rauc.readthedocs.io/en/latest/using.html#system-based-customization-handlers
[hook]: https://rauc.readthedocs.io/en/latest/using.html#bundle-based-customization-hooks
[linux]: https://github.com/raspberrypi/linux/commit/777a6a08bcf8f5f0a0086358dc66d8918a0e1c57#diff-1c6051b88ea21684666367f31afc5452e51abc9fe5f340281cd9d38459ac3d35R224-R225
[mailbox property interface]: https://github.com/raspberrypi/firmware/wiki/Mailbox-property-interface
[raspberrypi firmware driver]: https://github.com/raspberrypi/linux/blob/rpi-6.6.y/drivers/firmware/raspberrypi.c
[reboot(2)]: https://linux.die.net/man/2/reboot
[reboot]: https://www.freedesktop.org/software/systemd/man/latest/systemctl.html#reboot
[system.conf]: https://rauc.readthedocs.io/en/latest/reference.html#sec-ref-slot-config
[tryboot]: https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#fail-safe-os-updates-tryboot
[vcmailbox]: https://github.com/raspberrypi/utils/blob/master/vcmailbox/vcmailbox.c
