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

#include "mynetworkmanager.hh"
#include <QtNetwork/QNetworkDiskCache>

QNetworkAccessManager* MyNetworkManager::create(QObject *parent) {
    QNetworkAccessManager *nam = new MyNetworkAccessManager(parent);

    connect(nam, SIGNAL(sslErrors(QNetworkReply*,QList<QSslError>)), this, SLOT(onSslErrors(QNetworkReply*,QList<QSslError>)));
  //  connect(nam, SIGNAL(finished(QNetworkReply*)), this, SLOT(onReplyFinished(QNetworkReply*)));

    QNetworkDiskCache* diskCache = new QNetworkDiskCache(parent);
    diskCache->setCacheDirectory("/tmp");
    diskCache->setMaximumCacheSize(5*1024*1024); // 5Mo
    nam->setCache(diskCache);

    return nam;
}

QNetworkReply *MyNetworkAccessManager::createRequest( QNetworkAccessManager::Operation op, const QNetworkRequest & req, QIODevice * outgoingData) {
    QNetworkRequest request(req);
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);
    return QNetworkAccessManager::createRequest(op, request, outgoingData);
}

void MyNetworkManager::onSslErrors(QNetworkReply *reply, const QList<QSslError> &errors) {
    qDebug("onSslErrors");
    reply->ignoreSslErrors(errors);
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
