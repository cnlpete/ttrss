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

#include "qmlutils.hh"

#ifdef Q_OS_HARMATTAN
#include <MDataUri>
#include <maemo-meegotouch-interfaces/shareuiinterface.h>
#endif

QScopedPointer<QMLUtils> QMLUtils::m_instance(0);

QMLUtils::QMLUtils(QObject *parent) : QObject(parent) {
}

QMLUtils *QMLUtils::instance() {
    if (m_instance.isNull())
        m_instance.reset(new QMLUtils);

    return m_instance.data();
}

void QMLUtils::share(const QString &link, const QString &title) {
#ifdef Q_OS_HARMATTAN
    MDataUri uri;
    uri.setMimeType("text/x-url");

    uri.setTextData(link);

    if (!title.isEmpty())
        uri.setAttribute("title", title);

    if (!uri.isValid()) {
        qCritical("QMLUtils::shareLink(): Invalid URI");
        return;
    }

    ShareUiInterface shareIf("com.nokia.ShareUi");

    if (!shareIf.isValid()) {
        qCritical("QMLUtils::shareLink(): Invalid Share UI interface");
        return;
    }

    shareIf.share(QStringList() << uri.toString());
#else
    qWarning("QMLUtils::shareLink(): This function only available on Harmattan");
    Q_UNUSED(title)
    Q_UNUSED(link)
#endif
}
