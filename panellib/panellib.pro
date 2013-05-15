include(../common.pri)

TEMPLATE = lib
TARGET = Panels
QT += declarative dbus
CONFIG += qt \
    plugin \
    link_pkgconfig \
    declarative
TARGET = $$qtLibraryTarget($$TARGET)
DESTDIR = $$TARGET
OBJECTS_DIR = .obj
MOC_DIR = .moc

# Input
SOURCES += \
    panelsplugin.cpp \
    panelobj.cpp \
    panelmodel.cpp \
    panelproxymodel.cpp \
    musicinterface.cpp \
    qmldbusmusic.cpp

OTHER_FILES += \
    Panels/*.qml \
    Panels/qmldir \
    Panels/panelsMove.js


HEADERS += \
    panelsplugin.h \
    panelobj.h \
    panelmodel.h \
    panelproxymodel.h \
    musicinterface.h \
    qmldbusmusic.h

qmldir.files += $$TARGET
qmldir.path += $$[QT_INSTALL_IMPORTS]/MeeGo/
INSTALLS += qmldir
