# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed

VERSION = 0.4.0
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

