# This file is part of TTRss, a Tiny Tiny RSS Reader App
# for MeeGo Harmattan and Sailfish OS.
# Copyright (C) 2012–2014  Hauke Schade
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

VERSION = 0.4.3
DEFINES += APP_VERSION=\\\"$$VERSION\\\"

# Add more folders to ship with the application, here
folder_01.source = qml/ttrss/models
folder_01.target = qml
folder_02.source = qml/ttrss/harmattan
folder_02.target = qml
folder_03.source = qml/ttrss/components
folder_03.target = qml
folder_04.source = qml/ttrss/resources
folder_04.target = qml
DEPLOYMENTFOLDERS = folder_01 folder_02 folder_03 folder_04

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

symbian:TARGET.UID3 = 0xE29C50DC

# Smart Installer package's UID
# This UID is from the protected range and therefore the package will
# fail to install if self-signed. By default qmake uses the unprotected
# range value if unprotected UID is defined for the application and
# 0x2002CCCF value if protected UID is given to the application
#symbian:DEPLOYMENT.installer_header = 0x2002CCCF

# Allow network access on Symbian
symbian:TARGET.CAPABILITY += NetworkServices

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
# CONFIG += mobility
# MOBILITY +=

# Speed up launching on MeeGo/Harmattan when using applauncherd daemon
CONFIG += qdeclarative-boostable

contains(MEEGO_EDITION,harmattan) {
    # disable to make builds for use with meecolay
    CONFIG += shareuiinterface-maemo-meegotouch share-ui-plugin share-ui-common
    DEFINES += Q_OS_HARMATTAN
}

# Add dependency to Symbian components
# CONFIG += qt-components

# The .cpp files
SOURCES += main.cpp \
    settings.cpp \
    mynetworkmanager.cpp \
    qmlutils.cpp \
    theme.cpp

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

RESOURCES += \
    harmattan.qrc

HEADERS += \
    settings.hh \
    mynetworkmanager.hh \
    qmlutils.hh \
    theme.hh

OTHER_FILES += \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/manifest.aegis \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog

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

TRANSLATIONS += i18n/qml-translation.cs.ts \
    i18n/qml-translation.de.ts \
    i18n/qml-translation.en.ts \
    i18n/qml-translation.es.ts \
    i18n/qml-translation.fr.ts \
    i18n/qml-translation.ru.ts \
    i18n/qml-translation.zh_CN.ts

contains(MEEGO_EDITION,harmattan) {
    icon.files = images/ttrss80.png
    icon.path = /usr/share/icons/hicolor/80x80/apps
    INSTALLS += icon

    splash.files = images/ttrss-splash-portrait.jpg images/ttrss-splash-landscape.jpg
    splash.path = /opt/$${TARGET}/splash
    INSTALLS += splash
}
