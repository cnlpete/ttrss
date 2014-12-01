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

#ifndef SETTINGS_HH
#define SETTINGS_HH

#include <QtCore/QObject>
#include <QtCore/QScopedPointer>
#include <QtCore/qstring.h>
#include <QtNetwork/QSsl>

class QSettings;

class Settings : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString servername READ servername WRITE setServername NOTIFY servernameChanged)
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)

    Q_PROPERTY(QString httpauthusername READ httpauthUsername WRITE setHttpauthUsername NOTIFY httpauthUsernameChanged)
    Q_PROPERTY(QString httpauthpassword READ httpauthPassword WRITE setHttpauthPassword NOTIFY httpauthPasswordChanged)
    Q_PROPERTY(bool ignoreSSLErrors READ ignoreSSLErrors WRITE setIgnoreSSLErrors NOTIFY ignoreSSLErrorsChanged)
    Q_PROPERTY(int minSSLVersion READ minSSLVersion WRITE setMinSSLVersion NOTIFY minSSLVersionChanged)

    Q_PROPERTY(bool autologin READ hasAutologin WRITE setAutologin NOTIFY autologinChanged)
    Q_PROPERTY(bool useAutologin READ hasUseAutologin WRITE setUseAutologin NOTIFY useAutologinChanged)

    Q_PROPERTY(bool whiteTheme READ isWhiteTheme WRITE setWhiteTheme NOTIFY whiteThemeChanged)
    Q_PROPERTY(int feeditemsOrder READ feeditemsOrder WRITE setFeeditemsOrder NOTIFY feeditemsOrderChanged)
    Q_PROPERTY(bool displayIcons READ displayIcons WRITE setDisplayIcons NOTIFY displayIconsChanged)
    Q_PROPERTY(int webviewFontSize READ webviewFontSize WRITE setWebviewFontSize NOTIFY webviewFontSizeChanged)
    Q_PROPERTY(bool autoMarkRead READ autoMarkRead WRITE setAutoMarkRead NOTIFY autoMarkReadChanged)
    Q_PROPERTY(bool useAllFeedsOnStartup READ useAllFeedsOnStartup WRITE setUseAllFeedsOnStartup NOTIFY useAllFeedsOnStartupChanged)
    Q_PROPERTY(bool whiteBackgroundOnIcons READ whiteBackgroundOnIcons WRITE setWhiteBackgroundOnIcons NOTIFY whiteBackgroundOnIconsChanged)
    Q_PROPERTY(bool showAll READ showAll WRITE setShowAll NOTIFY showAllChanged)
    Q_PROPERTY(bool displayImages READ displayImages WRITE setDisplayImages NOTIFY displayImagesChanged)
    Q_PROPERTY(bool stripInvisibleImg READ stripInvisibleImg WRITE setStripInvisibleImg NOTIFY stripInvisibleImgChanged)
    Q_PROPERTY(bool displayLabels READ displayLabels WRITE setDisplayLabels NOTIFY displayLabelsChanged)
public:
    static Settings *instance();

    QString servername() const {
        return this->_servername;
    }
    void setServername(QString servername);

    QString username() const {
        return this->_username;
    }
    void setUsername(QString username);

    QString password() const {
        return this->_password;
    }
    void setPassword(QString password);

    QString httpauthUsername() const {
        return this->_httpauthuser;
    }
    void setHttpauthUsername(QString username);

    QString httpauthPassword() const {
        return this->_httpauthpasswd;
    }
    void setHttpauthPassword(QString password);

    bool ignoreSSLErrors() const {
        return this->_ignoreSSLErrors;
    }
    void setIgnoreSSLErrors(bool ignoreSSLErrors);

    int minSSLVersion() const {
        return this->_minSSLVersion;
    }
    void setMinSSLVersion(int minSSLVersion);
    QSsl::SslProtocol getMinSSLVersion() const;
    bool isMinSSlVersionGreaterThan(QSsl::SslProtocol otherVersion) const;

    bool hasAutologin() const {
        return this->_autologin;
    }
    void setAutologin(bool autologin);

    bool hasUseAutologin() const {
        return this->_useAutologin;
    }
    void setUseAutologin(bool useAutologin);

    bool isWhiteTheme() const {
        return this->_whiteTheme;
    }
    void setWhiteTheme(bool whiteTheme);

    bool feeditemsOrder() const {
        return this->_feeditemsOrder;
    }
    void setFeeditemsOrder(int feeditemsOrder);

    bool displayIcons() const {
        return this->_displayIcons;
    }
    void setDisplayIcons(bool displayIcons);

    int webviewFontSize() const {
        return this->_webviewFontSize;
    }
    void setWebviewFontSize(int webviewFontSize);

    bool autoMarkRead() const {
        return this->_autoMarkRead;
    }
    void setAutoMarkRead(bool autoMarkRead);

    bool useAllFeedsOnStartup() const {
        return this->_useAllFeedsOnStartup;
    }
    void setUseAllFeedsOnStartup(bool useAllFeedsOnStartup);

    bool whiteBackgroundOnIcons() const {
        return this->_whiteBackgroundOnIcons;
    }
    void setWhiteBackgroundOnIcons(bool whiteBackgroundOnIcons);

    bool showAll() const {
        return this->_showAll;
    }
    void setShowAll(bool showAll);

    bool displayImages() const {
        return this->_displayImages;
    }
    void setDisplayImages(bool displayImages);

    bool stripInvisibleImg() const {
        return this->_stripInvisibleImg;
    }
    void setStripInvisibleImg(bool stripInvisibleImg);

    bool displayLabels() const {
        return this->_displayLabels;
    }
    void setDisplayLabels(bool displayLabels);

signals:
    void servernameChanged();
    void usernameChanged();
    void passwordChanged();
<<<<<<< HEAD
=======
    void httpauthUsernameChanged();
    void httpauthPasswordChanged();
    void ignoreSSLErrorsChanged();
    void minSSLVersionChanged();

    // Startup
>>>>>>> ddc766e... [sailfish] added a minSSLVersion option, regards #117
    void autologinChanged();
    void useAutologinChanged();
    void ignoreSSLErrorsChanged();

    void httpauthUsernameChanged();
    void httpauthPasswordChanged();

    void whiteThemeChanged();
    void feeditemsOrderChanged();
    void displayIconsChanged();
    void webviewFontSizeChanged();
    void autoMarkReadChanged();
    void useAllFeedsOnStartupChanged();
    void whiteBackgroundOnIconsChanged();
    void showAllChanged();
    void displayImagesChanged();
    void stripInvisibleImgChanged();
    void displayLabelsChanged();

private:
    static QScopedPointer<Settings> m_instance;

    explicit Settings(QObject *parent = 0);
    Q_DISABLE_COPY(Settings)

    QSettings *m_settings;

    QString _servername;
    QString _username;
    QString _password;
<<<<<<< HEAD
=======
    QString _httpauthuser;
    QString _httpauthpasswd;
    bool _ignoreSSLErrors;
    int _minSSLVersion;

    // Startup
>>>>>>> ddc766e... [sailfish] added a minSSLVersion option, regards #117
    bool _autologin;
    bool _useAutologin;
    bool _ignoreSSLErrors;

    QString _httpauthuser;
    QString _httpauthpasswd;

    bool _whiteTheme;
    int _feeditemsOrder;
    bool _displayIcons;
    int _webviewFontSize;
    bool _autoMarkRead;
    bool _useAllFeedsOnStartup;
    bool _whiteBackgroundOnIcons;
    bool _showAll;
    bool _displayImages;
    bool _stripInvisibleImg;
    bool _displayLabels;
};
#endif // SETTINGS_HH
