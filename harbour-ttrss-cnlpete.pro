# This file is part of TTRss, a Tiny Tiny RSS Reader App
# for MeeGo Harmattan and Sailfish OS.
# Copyright (C) 2012–2015  Hauke Schade
#
# TTRss is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# TTRss is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with TTRss; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA or see
# http://www.gnu.org/licenses/.

DEFINES += APP_VERSION=\\\"$$VERSION\\\"

DEFINES += Q_OS_SAILFISH

TARGET = harbour-ttrss-cnlpete
DEFINES += TARGET=\\\"$$TARGET\\\"

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

icon86.files += images/icons/86x86/$${TARGET}.png
icon86.path = /usr/share/icons/hicolor/86x86/apps
INSTALLS += icon86
icon108.files += images/icons/108x108/$${TARGET}.png
icon108.path = /usr/share/icons/hicolor/108x108/apps
INSTALLS += icon108
icon128.files += images/icons/128x128/$${TARGET}.png
icon128.path = /usr/share/icons/hicolor/128x128/apps
INSTALLS += icon128
icon172.files += images/icons/172x172/$${TARGET}.png
icon172.path = /usr/share/icons/hicolor/172x172/apps
INSTALLS += icon172
icon256.files += images/icons/256x256/$${TARGET}.png
icon256.path = /usr/share/icons/hicolor/256x256/apps
INSTALLS += icon256
#iconsvg.files += images/icons/scalable/$${TARGET}.svgz
#iconsvg.path = /usr/share/icons/hicolor/scalable/apps

desktop.files = $${TARGET}.desktop
desktop.path = /usr/share/applications
INSTALLS += desktop

RESOURCES += \
    images.qrc \
    i18n.qrc

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
    rpm/$${TARGET}.changes \
    $$files(rpm/*) \
    $$files(qml/ttrss/harmattan/*) \
    $$files(qml/ttrss/components/*) \
    *.md

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
    i18n/qml-translation.et.ts \
    i18n/qml-translation.fr.ts \
    i18n/qml-translation.nl_NL.ts \
    i18n/qml-translation.pl.ts \
    i18n/qml-translation.ru.ts \
    i18n/qml-translation.ro.ts \
    i18n/qml-translation.sv.ts \
    i18n/qml-translation.zh_CN.ts
