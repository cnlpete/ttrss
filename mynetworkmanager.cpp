#include "mynetworkmanager.hh"

QNetworkAccessManager* MyNetworkManager::create(QObject *parent) {
    QNetworkAccessManager *nam = new QNetworkAccessManager(parent);

    connect(nam, SIGNAL(sslErrors(QNetworkReply*,QList<QSslError>)), this, SLOT(onSslErrors(QNetworkReply*,QList<QSslError>)));
  //  connect(nam, SIGNAL(finished(QNetworkReply*)), this, SLOT(onReplyFinished(QNetworkReply*)));

    qDebug("new custom mynetworkManager :)");
    return nam;
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
