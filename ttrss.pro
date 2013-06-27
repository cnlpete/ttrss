VERSION = 0.2.4
DEFINES += APP_VERSION=\\\"$$VERSION\\\"

# Add more folders to ship with the application, here
folder_01.source = qml/ttrss
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01

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

# disable to make builds for use with meecolay
CONFIG += shareuiinterface-maemo-meegotouch share-ui-plugin share-ui-common
DEFINES += Q_OS_HARMATTAN

# Add dependency to Symbian components
# CONFIG += qt-components

# The .cpp files
SOURCES += main.cpp \
    settings.cpp \
    mynetworkmanager.cpp \
    qmlutils.cpp

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

RESOURCES += \
    harmattan.qrc

HEADERS += \
    settings.hh \
    mynetworkmanager.hh \
    qmlutils.hh
