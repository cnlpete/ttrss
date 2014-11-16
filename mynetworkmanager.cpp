/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2014  Hauke Schade
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

#include <QtNetwork/QNetworkDiskCache>
#include <QtNetwork/QSslConfiguration>
#include <QtCore/QDebug>

#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
#include <QtCore/QStandardPaths>
#else
#include <QtCore/QDesktopServices>
#endif

#include "mynetworkmanager.hh"
#include "settings.hh"

QScopedPointer<MyNetworkManager> MyNetworkManager::m_instance(0);

MyNetworkManager *MyNetworkManager::instance() {
    if (m_instance.isNull())
        m_instance.reset(new MyNetworkManager);

    m_instance->_numRequests = 0;
    m_instance->_gotSSLError = false;
    return m_instance.data();
}

QNetworkAccessManager* MyNetworkManager::create(QObject *parent) {
    QNetworkAccessManager *nam = new MyNetworkAccessManager(parent);

    connect(nam, SIGNAL(sslErrors(QNetworkReply*,QList<QSslError>)), this, SLOT(onSslErrors(QNetworkReply*,QList<QSslError>)));
    connect(nam, SIGNAL(finished(QNetworkReply*)), this, SLOT(onReplyFinished(QNetworkReply*)));
    connect(nam, SIGNAL(started()), this, SLOT(onStarted()));
    connect(nam, SIGNAL(error()), this, SLOT(onError()));

#if !defined(Q_OS_SAILFISH)
    QNetworkDiskCache* diskCache = new QNetworkDiskCache(parent);
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
    QString cachePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
#else
    QString cachePath = QDesktopServices::storageLocation(QDesktopServices::CacheLocation);
#endif
    diskCache->setCacheDirectory(cachePath);
    diskCache->setMaximumCacheSize(5*1024*1024); // 5Mo
    nam->setCache(diskCache);
#endif

    return nam;
}

QNetworkReply *MyNetworkAccessManager::createRequest( QNetworkAccessManager::Operation op, const QNetworkRequest & req, QIODevice * outgoingData) {
    this->started();
    QNetworkRequest request(req);
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);
    QNetworkReply *reply = QNetworkAccessManager::createRequest(op, request, outgoingData);
    if (Settings::instance()->ignoreSSLErrors()) {
        reply->ignoreSslErrors();
    }
    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(onError(QNetworkReply::NetworkError)));
    return reply;
}

void MyNetworkAccessManager::onError(QNetworkReply::NetworkError e) {
    qDebug() << "got network error " << (int)e;

    if (e < QNetworkReply::ContentAccessDenied && e != QNetworkReply::TemporaryNetworkFailureError)
        this->error();
}

void MyNetworkManager::onError() {
    this->decNumRequests();
}

void MyNetworkManager::onSslErrors(QNetworkReply *reply, const QList<QSslError> &errors) {
    bool alreadyGotSSLError = this->gotSSLError();
    this->_gotSSLError = true;
    if (alreadyGotSSLError != this->_gotSSLError) {
        emit this->gotSSLErrorChanged();
    }

    if (Settings::instance()->ignoreSSLErrors()) {
        qDebug("onSslErrors");
        reply->ignoreSslErrors(errors);
    }
    else
        qDebug("not ignoring onSslErrors, since this is not specified in settings");
}

void MyNetworkManager::onStarted() {
    this->incNumRequests();
}

void MyNetworkManager::onReplyFinished(QNetworkReply *reply) {
    Q_UNUSED(reply);
    this->decNumRequests();
}

//void MyNetworkManager::onReplyFinished(QNetworkReply *reply) {
//    Q_ASSERT(reply);
//    if (!reply)
//        return;

//    if (reply->error() == QNetworkReply::NoError) {
//        return;
//    }

//    const int httpStatusCode = reply->attribute(
//                QNetworkRequest::HttpStatusCodeAttribute).toInt();
//    qDebug(QString("Network error = %1, HTTP code = %2, error description = '%3'")
//           .arg(reply->error())
//           .arg(httpStatusCode)
//           .arg(reply->errorString())
//           .toAscii());
//}
