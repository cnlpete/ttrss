//Copyright Hauke Schade, 2012-2013
//
//This file is part of TTRss.
//
//TTRss is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the
//Free Software Foundation, either version 2 of the License, or (at your option) any later version.
//TTRss is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with TTRss (on a Maemo/Meego system there is a copy
//in /usr/share/common-licenses. If not, see http://www.gnu.org/licenses/.

#if defined(Q_OS_SAILFISH)
    #include <QGuiApplication>
    #include <sailfishapp.h>
    #ifdef QT_QML_DEBUG
        #include <QtQuick>
    #endif
#else
    #include <QtGui/QApplication>
    #include <QtDeclarative/QDeclarativeContext>
    #include "qmlapplicationviewer.h"
#endif

#include <QTranslator>
#include <QLocale>

#include "settings.hh"
#include "qmlutils.hh"

#if defined(Q_OS_SAILFISH)
#else
    #include "mynetworkmanager.hh"
#endif

Q_DECL_EXPORT int main(int argc, char *argv[])
{
#if defined(Q_OS_SAILFISH)
    QGuiApplication *app = SailfishApp::application(argc, argv);
#else
    QScopedPointer<QApplication> app(createApplication(argc, argv));
#endif

    app->setApplicationVersion(APP_VERSION);
    app->setApplicationName("ttrss");
    app->setOrganizationName("Hauke Schade");

    QString locale = QLocale::system().name();
    QTranslator translator;
    /* the ":/" is a special directory Qt uses to
    * distinguish resources;
    * NB this will look for a filename matching locale + ".qm";
    * if that's not found, it will truncate the locale to
    * the first two characters (e.g. "en_GB" to "en") and look
    * for that + ".qm"; if not found, it will look for a
    * qml-translations.qm file; if not found, no translation is done
    */
    if (translator.load("qml-translation." + locale, ":/i18n"))
        app->installTranslator(&translator);

#if defined(Q_OS_SAILFISH)
    QQuickView* viewer = SailfishApp::createView();
#else
    QmlApplicationViewer *viewer = new QmlApplicationViewer();
    viewer->setOrientation(QmlApplicationViewer::ScreenOrientationAuto);

    //QObject::connect(viewer.engine(), SIGNAL(quit()), viewer.data, SLOT(close()));
    viewer->setNetworkAccessManagerFactory(MyNetworkManager::instance());
    viewer->rootContext()->setContextProperty("network", MyNetworkManager::instance());
#endif

    viewer->rootContext()->setContextProperty("APP_VERSION", APP_VERSION);

    viewer->rootContext()->setContextProperty("QMLUtils", QMLUtils::instance());
    viewer->rootContext()->setContextProperty("settings", Settings::instance());

#if defined(Q_OS_SAILFISH)
    viewer->setSource(SailfishApp::pathTo("qml/sailfish/harbour-ttrss.qml"));
#else
    viewer->setMainQmlFile(QLatin1String("qml/harmattan/main.qml"));
#endif

#if defined(Q_OS_SAILFISH)
    viewer->show();
#else
    viewer->showExpanded();
#endif

    return app->exec();
}
