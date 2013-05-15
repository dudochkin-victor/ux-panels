include(../../common.pri)
TEMPLATE = subdirs
PANEL_NAME=friends

panel.files = *.qml
panel.path = $$INSTALL_ROOT/usr/share/$$PROJECT_NAME/$$PANEL_NAME/

OTHER_FILES = *.qml

panel_desktop.files = desktop/*.panel
panel_desktop.path = $$INSTALL_ROOT/usr/share/$$PROJECT_NAME/panels

INSTALLS += panel panel_desktop

#********* Translations *********
PKG_NAME = meego-ux-panels-$${PANEL_NAME}
TRANSLATIONS += $${HEADERS} \
        $${SOURCES} \
        $${OTHER_FILES}
dist.commands += lupdate $${TRANSLATIONS} -ts $${TSDIR}/$${PKG_NAME}.ts

QMAKE_EXTRA_TARGETS += dist
#********* End Translations ******
