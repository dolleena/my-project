SUMMARY = "EdgeWatch agent"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
SRC_URI = "git://github.com/youruser/edgewatch.git;branch=main;protocol=https"
S = "${WORKDIR}/git/agent"

RDEPENDS:${PN} = "python3-core python3-requests"

do_install() {
    install -d ${D}${bindir}/edgewatch
    install -m 0755 ${S}/agent.py ${D}${bindir}/edgewatch/agent.py
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/edgewatch-agent.service ${D}${systemd_system_unitdir}/edgewatch-agent.service
}

SYSTEMD_SERVICE:${PN} = "edgewatch-agent.service"
