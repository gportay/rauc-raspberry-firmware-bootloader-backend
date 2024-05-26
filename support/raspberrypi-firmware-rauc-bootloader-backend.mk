################################################################################
#
# raspberrypi-firmware-rauc-bootloader-backend
#
################################################################################

RASPBERRYPI_FIRMWARE_RAUC_BOOTLOADER_BACKEND_VERSION = 1ecbd17d9e3b41f0faeccadb75a42460f3b3ce78
RASPBERRYPI_FIRMWARE_RAUC_BOOTLOADER_BACKEND_SITE = $(call github,gportay,raspberrypi-firmware-rauc-bootloader-backend,$(RASPBERRYPI_FIRMWARE_RAUC_BOOTLOADER_BACKEND_VERSION))
RASPBERRYPI_FIRMWARE_RAUC_BOOTLOADER_BACKEND_LICENSE = LGPL-2.1+
RASPBERRYPI_FIRMWARE_RAUC_BOOTLOADER_BACKEND_LICENSE_FILES = LICENSE

define RASPBERRYPI_FIRMWARE_RAUC_BOOTLOADER_BACKEND_INSTALL_TARGET_CMDS
	$(MAKE) -C $(@D) PREFIX=/usr DESTDIR=$(TARGET_DIR) install
endef

$(eval $(generic-package))
