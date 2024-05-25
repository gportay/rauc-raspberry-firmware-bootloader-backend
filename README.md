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
[EFI] bootloader backend. It is like an implementation boot-attempts counter of
1 after an update.

_Note_: The drawback is the firmware will not fallback to the other system if
the primary system gets unbootable for some reason.

The Raspberry Pi firmware RAUC custom bootloader backend parses or updates the
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

_Important_: The online documentation for [tryboot] tells to set the one-shot
flag in the `reboot` command as below:

	# Quotes are important. Reboot only accepts a single argument.
	sudo reboot '0 tryboot'

The kernel of the [Raspberry Pi hardwares] forwards the optional [reboot]
argument given to [reboot(2)] to the [raspberrypi firmware driver] before the
system is restarted. The driver submits the mailbox tag to the VPU firmware
through the [mailbox property interface].

It is highly undesirable to trigger a `reboot` from within RAUC to set the new
boot state. The firmware utility [vcmailbox] submits from the userspace thanks
to the [broadcom vcio driver].

_Note_: The tag **Set Reboot Flags** is not documented yet; It kernel reveals
it:

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

_Important_: The [broadcom vcio driver] is not supported upstream.

_Note_: The [backend] is written in [bash(1)].

## INSTALL

Run the following command to install *bootloader-custom-backend(1)* and
*rauc-mark-good.service(8)*

	$ sudo make install

Traditional variables *DESTDIR* and *PREFIX* can be overridden

	$ sudo make install PREFIX=/opt/dosh

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
[EFI]: https://rauc.readthedocs.io/en/latest/integration.html#efi
[Raspberry Pi hardwares]: https://www.raspberrypi.com/products/
[U-Boot]: https://rauc.readthedocs.io/en/latest/integration.html#id5
[autoboot.txt]: https://www.raspberrypi.com/documentation/computers/config_txt.html#autoboot-txt
[backend]: bootloader-custom-backend
[bash(1)]: https://linux.die.net/man/1/bash
[broadcom vcio driver]: https://github.com/raspberrypi/linux/blob/rpi-6.6.y/drivers/char/broadcom/vcio.c
[custom]: https://rauc.readthedocs.io/en/latest/integration.html#custom
[linux]: https://github.com/raspberrypi/linux/commit/777a6a08bcf8f5f0a0086358dc66d8918a0e1c57#diff-1c6051b88ea21684666367f31afc5452e51abc9fe5f340281cd9d38459ac3d35R224-R225
[mailbox property interface]: https://github.com/raspberrypi/firmware/wiki/Mailbox-property-interface
[raspberrypi firmware driver]: https://github.com/raspberrypi/linux/blob/rpi-6.6.y/drivers/firmware/raspberrypi.c
[reboot(2)]: https://linux.die.net/man/2/reboot
[reboot]: https://www.freedesktop.org/software/systemd/man/latest/systemctl.html#reboot
[tryboot]: https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#fail-safe-os-updates-tryboot
[vcmailbox]: https://github.com/raspberrypi/utils/blob/master/vcmailbox/vcmailbox.c
