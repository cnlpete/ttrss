#include <QTranslator>
#include <QLocale>
#include <QtGui/QApplication>
#include "qmlapplicationviewer.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));

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

    QmlApplicationViewer viewer;
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer.setMainQmlFile(QLatin1String("qml/ttrss/main.qml"));
    viewer.showExpanded();

    return app->exec();
}
