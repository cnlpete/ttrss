VERSION = 0.5.2
UBUNTU_REVISION = 0
DEFINES += APP_VERSION=\\\"$$VERSION\\\"

DEFINES += Q_OS_UBUNTU_TOUCH

TARGET = ttrss-ubuntu-touch
DEFINES += TARGET=\\\"it.mardy.ttrss\\\"

QT += quick qml

CLICK_DIR = $${OUT_PWD}/click
CLICK_ARCH = $$system("dpkg-architecture -qDEB_HOST_ARCH")
BUILD_ARCH = $$system("dpkg-architecture -qDEB_BUILD_ARCH")

target.path = $${CLICK_DIR}
INSTALLS += target

CONFIG += link_pkgconfig

OTHER_FILES += \
    $$files(qml/ttrss/ubuntu-touch/*.qml)

qml_1.files = qml/ttrss/ubuntu-touch
qml_1.path = $${CLICK_DIR}/qml
qml_2.files = qml/ttrss/models
qml_2.path = $${CLICK_DIR}/qml
qml_3.files = qml/ttrss/resources
qml_3.path = $${CLICK_DIR}/qml
INSTALLS += qml_1 qml_2 qml_3

resources.files = images/resources
resources.path = $${CLICK_DIR}/qml
INSTALLS += resources

icon.files = ubuntu/ttrss.svg
icon.path = $${CLICK_DIR}
INSTALLS += icon

QMAKE_SUBSTITUTES += ubuntu/ttrss.desktop.in
desktop.files = ubuntu/ttrss.desktop
desktop.path = $${CLICK_DIR}
INSTALLS += desktop

apparmor.files = ubuntu/ttrss.json
apparmor.path = $${CLICK_DIR}
INSTALLS += apparmor

QMAKE_SUBSTITUTES += ubuntu/manifest.json.in
manifest.files = ubuntu/manifest.json
manifest.path = $${CLICK_DIR}
INSTALLS += manifest

HEADERS += \
    settings.hh \
    mynetworkmanager.hh \
    qmlutils.hh

SOURCES += main.cpp \
    settings.cpp \
    mynetworkmanager.cpp \
    qmlutils.cpp

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

build_translations.target = build_translations
build_translations.commands += lrelease $${_PRO_FILE_}
QMAKE_EXTRA_TARGETS += build_translations

equals(CLICK_ARCH, $${BUILD_ARCH}) {
    PRE_TARGETDEPS += update_translations
    POST_TARGETDEPS += build_translations
} else {
    message("Cross compiling: disabling building of translations")
}

#qm.files = $$replace(TRANSLATIONS, .ts, .qm)
#qm.path = /usr/share/$${TARGET}/translations
#qm.CONFIG += no_check_exist

#INSTALLS += qm

TRANSLATIONS += i18n/qml-translation.cs.ts \
    i18n/qml-translation.de.ts \
    i18n/qml-translation.en.ts \
    i18n/qml-translation.es.ts \
    i18n/qml-translation.fr.ts \
    i18n/qml-translation.ro.ts \
    i18n/qml-translation.ru.ts \
    i18n/qml-translation.zh_CN.ts

click.target = click
click.depends = install
click.commands = "click build click"
QMAKE_EXTRA_TARGETS += click
