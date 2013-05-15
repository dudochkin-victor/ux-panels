include(common.pri)
TEMPLATE = subdirs
SUBDIRS += panellib panelsrc
TARGET=meego-ux-panels

share.files += \
    *.qml \
    panels/
share.path += $$INSTALL_ROOT/usr/share/$$TARGET

OTHER_FILES = *.qml */*.qml panellib/Panels/*.qml panellib/*.cpp panellib/*.h

INSTALLS += share

#********* Translations *********
TRANSLATIONS += $${SOURCES} $${HEADERS} $${OTHER_FILES}
PROJECT_NAME = meego-ux-panels
PKG_NAME = meego-ux-panels

dist.commands += rm -Rf $${PROJECT_NAME}-$${VERSION} &&
dist.commands += git clone . $${PROJECT_NAME}-$${VERSION} &&
dist.commands += rm -Rf $${PROJECT_NAME}-$${VERSION}/.git &&
dist.commands += mkdir -p $${PROJECT_NAME}-$${VERSION}/ts &&
dist.commands += lupdate $${TRANSLATIONS} -ts $${PROJECT_NAME}-$${VERSION}/ts/$${PKG_NAME}.ts &&
#dist.commands += cd panellib && make dist && cd .. &&
dist.commands += cd panelsrc && make dist && cd .. &&
dist.commands += tar jcpvf $${PROJECT_NAME}-$${VERSION}.tar.bz2 $${PROJECT_NAME}-$${VERSION}
QMAKE_EXTRA_TARGETS += dist
#********* End Translations ******
