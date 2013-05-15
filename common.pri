VERSION = 0.2.8
#CONFIG += debug


PROJECT_NAME = meego-ux-panels
BASEDIR = $$system(pwd)

DEFINES += "PANEL_DESKTOP_PATH=\\\"/usr/share/meego-ux-panels/panels\\\""
DEFINES += "SETTINGS_ORG=\\\"MeeGo\\\""
DEFINES += "SETTINGS_APP=\\\"meego-ux-panels\\\""


DISTDIR = $${BASEDIR}/$${PROJECT_NAME}-$${VERSION}
TSDIR = $${DISTDIR}/ts
