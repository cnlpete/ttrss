/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2014  Hauke Schade
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef MYNETWORKMANAGER_HH
#define MYNETWORKMANAGER_HH

#if defined(Q_OS_SAILFISH)
    #include <QQmlNetworkAccessManagerFactory>
#else
    #include <qdeclarativenetworkaccessmanagerfactory.h>
#endif

#include <QtNetwork/qnetworkreply.h>
#include <QtNetwork/QNetworkAccessManager>
#include <QMutex>
#include <QDebug>

#if defined(Q_OS_SAILFISH)
class MyNetworkManager : public QObject, public QQmlNetworkAccessManagerFactory
#else
class MyNetworkManager : public QObject, public QDeclarativeNetworkAccessManagerFactory
#endif
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
    QMutex _mutex;

    void incNumRequests() {
        QMutexLocker locker(&_mutex);
        _numRequests++;
        //qDebug() << "numReq is now " << _numRequests;
        if (_numRequests == 1)
            loadingChanged();
    }
    void decNumRequests() {
        QMutexLocker locker(&_mutex);
        _numRequests--;
        //qDebug() << "numReq is now " << _numRequests;
        // BUGFIX there are still scenarios where there is an error signal and a finished signal so this gets called twice :(
        // therefor try to limit scenarios where this would be decremented one too many
        if (_numRequests < 0)
            _numRequests = 0;
        if (_numRequests == 0)
            loadingChanged();
    }
};

class MyNetworkAccessManager : public QNetworkAccessManager {
    Q_OBJECT
public:
    MyNetworkAccessManager(QObject *parent = 0) : QNetworkAccessManager(parent) { }

private slots:
    void onError(QNetworkReply::NetworkError e);

signals:
    void started();
    void error();

protected:
    QNetworkReply *createRequest(Operation op, const QNetworkRequest &request, QIODevice *outgoingData = 0);

};

#endif // MYNETWORKMANAGER_HH
