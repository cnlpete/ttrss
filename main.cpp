/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2015  Hauke Schade
 *
 * TTRss is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * TTRss is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with TTRss; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA or see
 * http://www.gnu.org/licenses/.
 */

#include <QtGlobal>
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
    #include <QGuiApplication>
    #include <QQuickView>
    #include <QQmlEngine>
    #include <QQmlContext>
    #ifdef QT_QML_DEBUG
        #include <QtQuick>
    #endif
    #if defined(Q_OS_SAILFISH)
        #include <sailfishapp.h>
    #endif
#else
    #include <QtGui/QApplication>
    #include <QtDeclarative/QDeclarativeContext>
    #include "qmlapplicationviewer.h"
    #include <QDeclarativeEngine>
#endif

#include <QTranslator>
#include <QLocale>
#include <QFile>
#include <QDir>

#include "settings.hh"
#include "qmlutils.hh"
#include "mynetworkmanager.hh"

#if defined(Q_OS_HARMATTAN)
    #define USE_THEME
#endif
#if defined(USE_THEME)
    #include "theme.hh"
#endif

Q_DECL_EXPORT int main(int argc, char *argv[])
{
#if defined(Q_OS_SAILFISH)
    QGuiApplication *app = SailfishApp::application(argc, argv);
#elif (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
    QScopedPointer<QGuiApplication> app(new QGuiApplication(argc, argv));
#else
    QScopedPointer<QApplication> app(createApplication(argc, argv));
#endif

    app->setApplicationVersion(APP_VERSION);
    app->setApplicationName(TARGET);
    app->setOrganizationName(TARGET);

    // check for the old settings file, try to move it to new location
    QFileInfo settingsfileInfo(".config/Hauke Schade/ttrss.conf");
    QFile settingsfile(settingsfileInfo.absoluteFilePath());
    if (settingsfile.exists()) {
        if (!QDir(".config/" + QString(TARGET)).exists())
            QDir(".config/").mkdir(TARGET);
        QFileInfo newSettingsfileInfo(".config/" + QString(TARGET) + "/" + QString(TARGET) + ".conf");
        QFile newSettingsfile(newSettingsfileInfo.absoluteFilePath());
        if (newSettingsfile.exists())
            settingsfile.rename(".config/" + QString(TARGET) + "/" + QString(TARGET) + ".old.conf");
        else
            settingsfile.rename(".config/" + QString(TARGET) + "/" + QString(TARGET) + ".conf");
    }

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
#elif (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
    QScopedPointer<QQuickView> viewer(new QQuickView);
    viewer->setResizeMode(QQuickView::SizeRootObjectToView);
#else
    QmlApplicationViewer *viewer = new QmlApplicationViewer();
    viewer->setOrientation(QmlApplicationViewer::ScreenOrientationAuto);

    //QObject::connect(viewer.engine(), SIGNAL(quit()), viewer.data, SLOT(close()));
#endif
    viewer->engine()->setNetworkAccessManagerFactory(MyNetworkManager::instance());
    viewer->rootContext()->setContextProperty("network", MyNetworkManager::instance());

    viewer->rootContext()->setContextProperty("APP_VERSION", APP_VERSION);

    viewer->rootContext()->setContextProperty("QMLUtils", QMLUtils::instance());
    viewer->rootContext()->setContextProperty("settings", Settings::instance());

#ifdef USE_THEME
    viewer->rootContext()->setContextProperty("MyTheme", Theme::instance());
#endif

#if defined(Q_OS_SAILFISH)
    viewer->setSource(SailfishApp::pathTo("qml/sailfish/harbour-ttrss.qml"));
#else
    viewer->setMainQmlFile(QLatin1String("qml/harmattan/main.qml"));
#endif

#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
    viewer->show();
#else
    viewer->showExpanded();
#endif

    return app->exec();
}
