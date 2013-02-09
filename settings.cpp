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

#include "settings.hh"

#include <QtCore/QSettings>

QScopedPointer<Settings> Settings::m_instance(0);

Settings *Settings::instance() {
    if (m_instance.isNull())
        m_instance.reset(new Settings);

    return m_instance.data();
}

void Settings::setServername(QString servername) {
    if (_servername != servername) {
        _servername = servername;
        m_settings->setValue("servername", _servername);
        emit servernameChanged();
    }
}

void Settings::setUsername(QString username) {
    if (_username != username) {
        _username = username;
        m_settings->setValue("username", _username);
        emit usernameChanged();
    }
}

void Settings::setPassword(QString password) {
    if (_password != password) {
        _password = password;
        m_settings->setValue("password", _password);
        emit passwordChanged();
    }
}

void Settings::setAutologin(bool autologin) {
    if (_autologin != autologin) {
        _autologin = autologin;
        m_settings->setValue("autologin", _autologin);
        emit autologinChanged();
    }
}

void Settings::setWhiteTheme(bool whiteTheme) {
    if (_whiteTheme != whiteTheme) {
        _whiteTheme = whiteTheme;
        m_settings->setValue("whiteTheme", _whiteTheme);
        emit whiteThemeChanged();
    }
}

void Settings::setFeeditemsOrder(int feeditemsOrder) {
    if (_feeditemsOrder != feeditemsOrder) {
        _feeditemsOrder = feeditemsOrder;
        m_settings->setValue("feeditemsOrder", _feeditemsOrder);
        emit feeditemsOrderChanged();
    }
}

Settings::Settings(QObject *parent) : QObject(parent), m_settings(new QSettings(this)) {
    _servername = m_settings->value("servername", "http://").toString();
    _username = m_settings->value("username", "").toString();
    _password = m_settings->value("password", "").toString();
    _autologin = m_settings->value("autologin", false).toBool();

    _whiteTheme = m_settings->value("whiteTheme", true).toBool();
    _feeditemsOrder = m_settings->value("feeditemsOrder", 0).toInt();
}
