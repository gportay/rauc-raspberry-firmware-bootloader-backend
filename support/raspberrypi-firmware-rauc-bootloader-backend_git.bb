LICENSE = "LGPL-2.1-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=1803fa9c2c3ce8cb06b4861d75310742"

SRC_URI = "git://github.com/gportay/raspberrypi-firmware-rauc-bootloader-backend.git;protocol=https;branch=master"

PV = "1.0+git${SRCPV}"
SRCREV = "1ecbd17d9e3b41f0faeccadb75a42460f3b3ce78"

S = "${WORKDIR}/git"

inherit systemd

SYSTEMD_SERVICE:${PN} += "rauc-mark-good.service"

do_configure () {
	:
}

do_compile () {
	:
}

do_install () {
	install -D -m644 ${S}/rauc-mark-good.service ${D}${systemd_system_unitdir}/rauc-mark-good.service
}
