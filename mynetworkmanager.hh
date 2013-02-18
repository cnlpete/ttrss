#ifndef MYNETWORKMANAGER_HH
#define MYNETWORKMANAGER_HH

#include <qdeclarativenetworkaccessmanagerfactory.h>
#include <QtNetwork/qnetworkreply.h>

class MyNetworkManager : public QObject, public QDeclarativeNetworkAccessManagerFactory
{
    Q_OBJECT

public: // QDeclarativeNetworkAccessManagerFactory
    QNetworkAccessManager *create(QObject *parent);

private slots:
    void onSslErrors(QNetworkReply *reply, const QList<QSslError> &errors);
//    void onReplyFinished(QNetworkReply *reply);
};

#endif // MYNETWORKMANAGER_HH
