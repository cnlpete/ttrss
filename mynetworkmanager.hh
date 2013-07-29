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

#ifndef MYNETWORKMANAGER_HH
#define MYNETWORKMANAGER_HH

#include <qdeclarativenetworkaccessmanagerfactory.h>
#include <QtNetwork/qnetworkreply.h>
#include <QtNetwork/QNetworkAccessManager>

class MyNetworkManager : public QObject, public QDeclarativeNetworkAccessManagerFactory
{
    Q_OBJECT

    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public: // QDeclarativeNetworkAccessManagerFactory
    QNetworkAccessManager *create(QObject *parent);
    static MyNetworkManager *instance();

    bool loading() const {
        return this->_numRequests > 0;
    }

signals:
    void loadingChanged();

private slots:
    void onSslErrors(QNetworkReply *reply, const QList<QSslError> &errors);
    void onReplyFinished(QNetworkReply *reply);
    void onStarted();
    void onError();

private:
    static QScopedPointer<MyNetworkManager> m_instance;
    int _numRequests;
};

class MyNetworkAccessManager : public QNetworkAccessManager {
    Q_OBJECT
public:
    MyNetworkAccessManager(QObject *parent = 0) : QNetworkAccessManager(parent) { }

private slots:
    void onError();

signals:
    void started();
    void error();

protected:
    QNetworkReply *createRequest(Operation op, const QNetworkRequest &request, QIODevice *outgoingData = 0);

};

#endif // MYNETWORKMANAGER_HH
