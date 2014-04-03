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

void Settings::setHttpauthUsername(QString username) {
    if (_httpauthuser != username) {
        _httpauthuser = username;
        m_settings->setValue("httpauthusername", _httpauthuser);
        emit httpauthUsernameChanged();
    }
}

void Settings::setHttpauthPassword(QString password) {
    if (_httpauthpasswd != password) {
        _httpauthpasswd = password;
        m_settings->setValue("httpauthpassword", _httpauthpasswd);
        emit httpauthPasswordChanged();
    }
}

void Settings::setAutologin(bool autologin) {
    if (_autologin != autologin) {
        _autologin = autologin;
        m_settings->setValue("autologin", _autologin);
        emit autologinChanged();
    }
}

void Settings::setUseAutologin(bool useAutologin) {
    if (_useAutologin != useAutologin) {
        _useAutologin = useAutologin;
        m_settings->setValue("useAutologin", _useAutologin);
        emit useAutologinChanged();
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

void Settings::setDisplayIcons(bool displayIcons) {
    if (_displayIcons != displayIcons) {
        _displayIcons = displayIcons;
        m_settings->setValue("displayIcons", _displayIcons);
        emit displayIconsChanged();
    }
}

void Settings::setWebviewFontSize(int webviewFontSize) {
    if (_webviewFontSize != webviewFontSize) {
        _webviewFontSize = webviewFontSize;
        m_settings->setValue("webviewFontSize", _webviewFontSize);
        emit webviewFontSizeChanged();
    }
}

void Settings::setAutoMarkRead(bool autoMarkRead) {
    if (_autoMarkRead != autoMarkRead) {
        _autoMarkRead = autoMarkRead;
        m_settings->setValue("autoMarkRead", _autoMarkRead);
        emit autoMarkReadChanged();
    }
}

void Settings::setUseAllFeedsOnStartup(bool useAllFeedsOnStartup) {
    if (_useAllFeedsOnStartup != useAllFeedsOnStartup) {
        _useAllFeedsOnStartup = useAllFeedsOnStartup;
        m_settings->setValue("useAllFeedsOnStartup", _useAllFeedsOnStartup);
        emit useAllFeedsOnStartupChanged();
    }
}

void Settings::setWhiteBackgroundOnIcons(bool whiteBackgroundOnIcons()) {
    if (_whiteBackgroundOnIcons != whiteBackgroundOnIcons) {
        _whiteBackgroundOnIcons = whiteBackgroundOnIcons;
        m_settings->setValue("whiteBackgroundOnIcons", _whiteBackgroundOnIcons);
        emit whiteBackgroundOnIconsChanged();
    }
}

Settings::Settings(QObject *parent) : QObject(parent), m_settings(new QSettings(this)) {
    _servername = m_settings->value("servername", "http://").toString();
    _username = m_settings->value("username", "").toString();
    _password = m_settings->value("password", "").toString();
    _autologin = m_settings->value("autologin", false).toBool();
    _useAutologin = m_settings->value("useAutologin", true).toBool();

    _httpauthuser = m_settings->value("httpauthusername", "").toString();
    _httpauthpasswd = m_settings->value("httpauthpassword", "").toString();

    _whiteTheme = m_settings->value("whiteTheme", true).toBool();
    _feeditemsOrder = m_settings->value("feeditemsOrder", 0).toInt();
    _displayIcons = m_settings->value("displayIcons", true).toBool();
    _webviewFontSize = m_settings->value("webviewFontSize", 22).toInt();
    _autoMarkRead = m_settings->value("autoMarkRead", true).toBool();
    _useAllFeedsOnStartup = m_settings->value("useAllFeedsOnStartup", false).toBool();
    _whiteBackgroundOnIcons = m_settings->value("whiteBackgroundOnIcons", true).toBool();
}
