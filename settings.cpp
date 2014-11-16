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

#include "settings.hh"

#include <QtCore/QSettings>

QScopedPointer<Settings> Settings::m_instance(0);

Settings *Settings::instance() {
    if (m_instance.isNull())
        m_instance.reset(new Settings);

    return m_instance.data();
}

// Login Credentials
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

void Settings::setIgnoreSSLErrors(bool ignoreSSLErrors) {
    if (_ignoreSSLErrors != ignoreSSLErrors) {
        _ignoreSSLErrors = ignoreSSLErrors;
        m_settings->setValue("ignoreSSLErrors", _ignoreSSLErrors);
        emit ignoreSSLErrorsChanged();
    }
}

void Settings::setMinSSLVersion(int minSSLVersion) {
    if (_minSSLVersion != minSSLVersion) {
        _minSSLVersion = minSSLVersion;
        m_settings->setValue("minSSLVersion", _minSSLVersion);
        emit minSSLVersionChanged();
    }
}
QSsl::SslProtocol Settings::getMinSSLVersion() const {
    QSsl::SslProtocol minSSLVersionProtocol;
    switch (_minSSLVersion) {
    default:
    case 0:
        minSSLVersionProtocol = QSsl::AnyProtocol;
        break;
    case 1:
        minSSLVersionProtocol = QSsl::SslV2;
        break;
    case 2:
        minSSLVersionProtocol = QSsl::SslV3;
        break;
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
    case 3:
        minSSLVersionProtocol = QSsl::TlsV1_0;
        break;
    case 4:
        minSSLVersionProtocol = QSsl::TlsV1_1;
        break;
    case 5:
        minSSLVersionProtocol = QSsl::TlsV1_2;
        break;
#else
    case 3:
        minSSLVersionProtocol = QSsl::TlsV1;
        break;
#endif
    }
    return minSSLVersionProtocol;
}
bool Settings::isMinSSlVersionGreaterThan(QSsl::SslProtocol otherVersion) const {
    QSsl::SslProtocol currentVersion = this->getMinSSLVersion();

    bool result = false;
    switch (otherVersion) {
    case QSsl::SslV2:
        result = currentVersion == QSsl::SslV3 ||
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
                currentVersion == QSsl::TlsV1_0 ||
                currentVersion == QSsl::TlsV1_1 ||
                currentVersion == QSsl::TlsV1_2
#else
                currentVersion == QSsl::TlsV1
#endif
                ;
        break;
    case QSsl::SslV3:
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
    case QSsl::TlsV1SslV3:
    case QSsl::SecureProtocols:
        result = currentVersion == QSsl::TlsV1_0 ||
                currentVersion == QSsl::TlsV1_1 ||
                currentVersion == QSsl::TlsV1_2
#else
        result = currentVersion == QSsl::TlsV1
#endif
                ;
        break;
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
    case QSsl::TlsV1_0:
        result = currentVersion == QSsl::TlsV1_1 ||
                currentVersion == QSsl::TlsV1_2
                ;
        break;
    case QSsl::TlsV1_1:
        result = currentVersion == QSsl::TlsV1_2
                ;
        break;
    case QSsl::TlsV1_2:
#else
    case QSsl::TlsV1:
#endif
    case QSsl::UnknownProtocol:
        result = false;
        break;
    case QSsl::AnyProtocol:
        result = currentVersion != QSsl::AnyProtocol;
        break;
    }

    return result;
}

// Startup
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

void Settings::setUseAllFeedsOnStartup(bool useAllFeedsOnStartup) {
    if (_useAllFeedsOnStartup != useAllFeedsOnStartup) {
        _useAllFeedsOnStartup = useAllFeedsOnStartup;
        m_settings->setValue("useAllFeedsOnStartup", _useAllFeedsOnStartup);
        emit useAllFeedsOnStartupChanged();
    }
}

// Feeds
void Settings::setDisplayIcons(bool displayIcons) {
    if (_displayIcons != displayIcons) {
        _displayIcons = displayIcons;
        m_settings->setValue("displayIcons", _displayIcons);
        emit displayIconsChanged();
    }
}

void Settings::setWhiteBackgroundOnIcons(bool whiteBackgroundOnIcons) {
    if (_whiteBackgroundOnIcons != whiteBackgroundOnIcons) {
        _whiteBackgroundOnIcons = whiteBackgroundOnIcons;
        m_settings->setValue("whiteBackgroundOnIcons", _whiteBackgroundOnIcons);
        emit whiteBackgroundOnIconsChanged();
    }
}

// Item List
void Settings::setFeeditemsOrder(int feeditemsOrder) {
    if (_feeditemsOrder != feeditemsOrder) {
        _feeditemsOrder = feeditemsOrder;
        m_settings->setValue("feeditemsOrder", _feeditemsOrder);
        emit feeditemsOrderChanged();
    }
}

void Settings::setLengthOfTitle(int lengthOfTitle) {
    if (_lengthOfTitle != lengthOfTitle) {
        _lengthOfTitle = lengthOfTitle;
        m_settings->setValue("lengthOfTitle", _lengthOfTitle);
        emit lengthOfTitleChanged();
    }
}

void Settings::setShowExcerpt(bool showExcerpt) {
    if (_showExcerpt != showExcerpt) {
        _showExcerpt = showExcerpt;
        m_settings->setValue("showExcerpt", _showExcerpt);
        emit showExcerptChanged();
    }
}

void Settings::setLengthOfExcerpt(int lengthOfExcerpt) {
    if (_lengthOfExcerpt != lengthOfExcerpt) {
        _lengthOfExcerpt = lengthOfExcerpt;
        m_settings->setValue("lengthOfExcerpt", _lengthOfExcerpt);
        emit lengthOfExcerptChanged();
    }
}

void Settings::setDisplayLabels(bool displayLabels) {
    if (_displayLabels != displayLabels) {
        _displayLabels = displayLabels;
        m_settings->setValue("displayLabels", _displayLabels);
        emit displayLabelsChanged();
    }
}

void Settings::setShowNote(bool showNote) {
    if (_showNote != showNote) {
        _showNote = showNote;
        m_settings->setValue("showNote", _showNote);
        emit showNoteChanged();
    }
}

void Settings::setLengthOfNote(int lengthOfNote) {
    if (_lengthOfNote != lengthOfNote) {
        _lengthOfNote = lengthOfNote;
        m_settings->setValue("lengthOfNote", _lengthOfNote);
        emit lengthOfNoteChanged();
    }
}

// Items
void Settings::setAutoMarkRead(bool autoMarkRead) {
    if (_autoMarkRead != autoMarkRead) {
        _autoMarkRead = autoMarkRead;
        m_settings->setValue("autoMarkRead", _autoMarkRead);
        emit autoMarkReadChanged();
    }
}

void Settings::setDisplayImages(bool displayImages) {
    if (_displayImages != displayImages) {
        _displayImages = displayImages;
        m_settings->setValue("displayImages", _displayImages);
        emit displayImagesChanged();
    }
}

void Settings::setStripInvisibleImg(bool stripInvisibleImg) {
    if (_stripInvisibleImg != stripInvisibleImg) {
        _stripInvisibleImg = stripInvisibleImg;
        m_settings->setValue("stripInvisibleImg", _stripInvisibleImg);
        emit stripInvisibleImgChanged();
    }
}

void Settings::setWebviewFontSize(int webviewFontSize) {
    if (_webviewFontSize != webviewFontSize) {
        _webviewFontSize = webviewFontSize;
        m_settings->setValue("webviewFontSize", _webviewFontSize);
        emit webviewFontSizeChanged();
    }
}

// Harmattan
void Settings::setWhiteTheme(bool whiteTheme) {
    if (_whiteTheme != whiteTheme) {
        _whiteTheme = whiteTheme;
        m_settings->setValue("whiteTheme", _whiteTheme);
        emit whiteThemeChanged();
    }
}

// Other
void Settings::setShowAll(bool showAll) {
    if (_showAll != showAll) {
        _showAll = showAll;
        m_settings->setValue("showAll", _showAll);
        emit showAllChanged();
    }
}

Settings::Settings(QObject *parent) : QObject(parent), m_settings(new QSettings(this)) {
    // Login Credentials
    _servername = m_settings->value("servername", "http://").toString();
    _username = m_settings->value("username", "").toString();
    _password = m_settings->value("password", "").toString();
    _httpauthuser = m_settings->value("httpauthusername", "").toString();
    _httpauthpasswd = m_settings->value("httpauthpassword", "").toString();
    _ignoreSSLErrors = m_settings->value("ignoreSSLErrors", false).toBool();
    _minSSLVersion = m_settings->value("minSSLVersion", 0).toInt();

    // Startup
    _autologin = m_settings->value("autologin", false).toBool();
    _useAutologin = m_settings->value("useAutologin", true).toBool();
    _useAllFeedsOnStartup = m_settings->value("useAllFeedsOnStartup", false).toBool();

    // Feeds
    _displayIcons = m_settings->value("displayIcons", true).toBool();
    _whiteBackgroundOnIcons = m_settings->value("whiteBackgroundOnIcons", true).toBool();

    // Item List
    _feeditemsOrder = m_settings->value("feeditemsOrder", 0).toInt();
    _lengthOfTitle = m_settings->value("lengthOfTitle", 2).toInt();
    _showExcerpt = m_settings->value("showExcerpt", true).toBool();
    _lengthOfExcerpt = m_settings->value("lengthOfExcerpt", 2).toInt();
    _displayLabels = m_settings->value("displayLabels", true).toBool();
    _showNote = m_settings->value("showNote", true).toBool();
    _lengthOfNote = m_settings->value("lengthOfNote", 2).toInt();

    // Items
    _autoMarkRead = m_settings->value("autoMarkRead", true).toBool();
    _displayImages = m_settings->value("displayImages", true).toBool();
    _stripInvisibleImg = m_settings->value("stripInvisibleImg", false).toBool();
    _webviewFontSize = m_settings->value("webviewFontSize", 22).toInt();

    // Harmattan
    _whiteTheme = m_settings->value("whiteTheme", true).toBool();

    // Other
    _showAll = m_settings->value("showAll", false).toBool();
}
