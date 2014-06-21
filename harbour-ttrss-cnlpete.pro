# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed

VERSION = 0.4.3
DEFINES += APP_VERSION=\\\"$$VERSION\\\"

DEFINES += Q_OS_SAILFISH

TARGET = harbour-ttrss-cnlpete

##CONFIG += sailfishapp

QT += quick qml

target.path = /usr/bin
INSTALLS += target

CONFIG += link_pkgconfig
PKGCONFIG += sailfishapp
INCLUDEPATH += /usr/include/sailfishapp

qml_1.files = qml/ttrss/sailfish
qml_1.path = $$INSTALL_ROOT/usr/share/$$TARGET/qml
qml_2.files = qml/ttrss/models
qml_2.path = $$INSTALL_ROOT/usr/share/$$TARGET/qml
qml_3.files = qml/ttrss/resources
qml_3.path = $$INSTALL_ROOT/usr/share/$$TARGET/qml
INSTALLS += qml_1 qml_2 qml_3

icon.files = images/$${TARGET}.png
icon.path = /usr/share/icons/hicolor/86x86/apps
INSTALLS += icon

desktop.files = $${TARGET}.desktop
desktop.path = /usr/share/applications
INSTALLS += desktop

RESOURCES += \
    harmattan.qrc

HEADERS += \
    settings.hh \
    mynetworkmanager.hh \
    qmlutils.hh

SOURCES += main.cpp \
    settings.cpp \
    mynetworkmanager.cpp \
    qmlutils.cpp

OTHER_FILES += rpm/$${TARGET}.spec \
    rpm/$${TARGET}.yaml \
    $$files(rpm/*) \
    $$files(qml/ttrss/harmattan/*)

TS_FILE = $${_PRO_FILE_PWD_}/i18n/$${TARGET}.ts

# Translation source directories
TRANSLATION_SOURCE_CANDIDATES = $${_PRO_FILE_PWD_}/src $${_PRO_FILE_PWD_}/qml
for(dir, TRANSLATION_SOURCE_CANDIDATES) {
    exists($$dir) {
        TRANSLATION_SOURCES += $$dir
    }
}

# The target would really be $$TS_FILE, but we use a non-file target to emulate .PHONY
update_translations.target = update_translations
update_translations.commands += mkdir -p translations && lupdate $${TRANSLATION_SOURCES} -ts $${TS_FILE}
QMAKE_EXTRA_TARGETS += update_translations
PRE_TARGETDEPS += update_translations

build_translations.target = build_translations
build_translations.commands += lrelease $${_PRO_FILE_}
QMAKE_EXTRA_TARGETS += build_translations
POST_TARGETDEPS += build_translations

#qm.files = $$replace(TRANSLATIONS, .ts, .qm)
#qm.path = /usr/share/$${TARGET}/translations
#qm.CONFIG += no_check_exist

#INSTALLS += qm

TRANSLATIONS += i18n/qml-translation.cs.ts \
    i18n/qml-translation.de.ts \
    i18n/qml-translation.en.ts \
    i18n/qml-translation.es.ts \
    i18n/qml-translation.fr.ts \
    i18n/qml-translation.ru.ts \
    i18n/qml-translation.zh_CN.ts
