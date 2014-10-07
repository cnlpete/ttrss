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

class QSettings;

class Settings : public QObject
{
    Q_OBJECT

    // Login Credentials
    Q_PROPERTY(QString servername READ servername WRITE setServername NOTIFY servernameChanged)
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
    Q_PROPERTY(QString httpauthusername READ httpauthUsername WRITE setHttpauthUsername NOTIFY httpauthUsernameChanged)
    Q_PROPERTY(QString httpauthpassword READ httpauthPassword WRITE setHttpauthPassword NOTIFY httpauthPasswordChanged)
    Q_PROPERTY(bool ignoreSSLErrors READ ignoreSSLErrors WRITE setIgnoreSSLErrors NOTIFY ignoreSSLErrorsChanged)

    // Startup
    Q_PROPERTY(bool autologin READ hasAutologin WRITE setAutologin NOTIFY autologinChanged)
    Q_PROPERTY(bool useAutologin READ hasUseAutologin WRITE setUseAutologin NOTIFY useAutologinChanged)
    Q_PROPERTY(bool useAllFeedsOnStartup READ useAllFeedsOnStartup WRITE setUseAllFeedsOnStartup NOTIFY useAllFeedsOnStartupChanged)

    // Feeds
    Q_PROPERTY(bool displayIcons READ displayIcons WRITE setDisplayIcons NOTIFY displayIconsChanged)
    Q_PROPERTY(bool whiteBackgroundOnIcons READ whiteBackgroundOnIcons WRITE setWhiteBackgroundOnIcons NOTIFY whiteBackgroundOnIconsChanged)

    // Item List
    Q_PROPERTY(int feeditemsOrder READ feeditemsOrder WRITE setFeeditemsOrder NOTIFY feeditemsOrderChanged)
    Q_PROPERTY(int lengthOfTitle READ lengthOfTitle WRITE setLengthOfTitle NOTIFY lengthOfTitleChanged)
    Q_PROPERTY(bool showExcerpt READ showExcerpt WRITE setShowExcerpt NOTIFY showExcerptChanged)
    Q_PROPERTY(int lengthOfExcerpt READ lengthOfExcerpt WRITE setLengthOfExcerpt NOTIFY lengthOfExcerptChanged)
    Q_PROPERTY(bool displayLabels READ displayLabels WRITE setDisplayLabels NOTIFY displayLabelsChanged)

    // Items
    Q_PROPERTY(bool autoMarkRead READ autoMarkRead WRITE setAutoMarkRead NOTIFY autoMarkReadChanged)
    Q_PROPERTY(bool displayImages READ displayImages WRITE setDisplayImages NOTIFY displayImagesChanged)
    Q_PROPERTY(bool stripInvisibleImg READ stripInvisibleImg WRITE setStripInvisibleImg NOTIFY stripInvisibleImgChanged)
    Q_PROPERTY(int webviewFontSize READ webviewFontSize WRITE setWebviewFontSize NOTIFY webviewFontSizeChanged)

    // Harmattan
    Q_PROPERTY(bool whiteTheme READ isWhiteTheme WRITE setWhiteTheme NOTIFY whiteThemeChanged)

    // Other
    Q_PROPERTY(bool showAll READ showAll WRITE setShowAll NOTIFY showAllChanged)

public:
    static Settings *instance();

    // Login Credentials
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

    // Startup
    bool hasAutologin() const {
        return this->_autologin;
    }
    void setAutologin(bool autologin);

    bool hasUseAutologin() const {
        return this->_useAutologin;
    }
    void setUseAutologin(bool useAutologin);

    bool useAllFeedsOnStartup() const {
        return this->_useAllFeedsOnStartup;
    }
    void setUseAllFeedsOnStartup(bool useAllFeedsOnStartup);

    // Feeds
    bool displayIcons() const {
        return this->_displayIcons;
    }
    void setDisplayIcons(bool displayIcons);

    bool whiteBackgroundOnIcons() const {
        return this->_whiteBackgroundOnIcons;
    }
    void setWhiteBackgroundOnIcons(bool whiteBackgroundOnIcons);

    // Item List
    int feeditemsOrder() const {
        return this->_feeditemsOrder;
    }
    void setFeeditemsOrder(int feeditemsOrder);

    int lengthOfTitle() const {
        return this->_lengthOfTitle;
    }
    void setLengthOfTitle(int lengthOfTitle);

    bool showExcerpt() const {
        return this->_showExcerpt;
    }
    void setShowExcerpt(bool showExcerpt);

    int lengthOfExcerpt() const {
        return this->_lengthOfExcerpt;
    }
    void setLengthOfExcerpt(int lengthOfExcerpt);

    bool displayLabels() const {
        return this->_displayLabels;
    }
    void setDisplayLabels(bool displayLabels);

    // Items
    bool autoMarkRead() const {
        return this->_autoMarkRead;
    }
    void setAutoMarkRead(bool autoMarkRead);

    bool displayImages() const {
        return this->_displayImages;
    }
    void setDisplayImages(bool displayImages);

    bool stripInvisibleImg() const {
        return this->_stripInvisibleImg;
    }
    void setStripInvisibleImg(bool stripInvisibleImg);

    int webviewFontSize() const {
        return this->_webviewFontSize;
    }
    void setWebviewFontSize(int webviewFontSize);

    // Harmattan
    bool isWhiteTheme() const {
        return this->_whiteTheme;
    }
    void setWhiteTheme(bool whiteTheme);

    // Other
    bool showAll() const {
        return this->_showAll;
    }
    void setShowAll(bool showAll);

signals:
    // Login Credentials
    void servernameChanged();
    void usernameChanged();
    void passwordChanged();
    void httpauthUsernameChanged();
    void httpauthPasswordChanged();
    void ignoreSSLErrorsChanged();

    // Startup
    void autologinChanged();
    void useAutologinChanged();
    void useAllFeedsOnStartupChanged();

    // Feeds
    void displayIconsChanged();
    void whiteBackgroundOnIconsChanged();

    // Item List
    void feeditemsOrderChanged();
    void lengthOfTitleChanged();
    void showExcerptChanged();
    void lengthOfExcerptChanged();
    void displayLabelsChanged();

    // Items
    void autoMarkReadChanged();
    void displayImagesChanged();
    void stripInvisibleImgChanged();
    void webviewFontSizeChanged();

    // Harmattan
    void whiteThemeChanged();

    // Other
    void showAllChanged();

private:
    static QScopedPointer<Settings> m_instance;

    explicit Settings(QObject *parent = 0);
    Q_DISABLE_COPY(Settings)

    QSettings *m_settings;

    // Login Credentials
    QString _servername;
    QString _username;
    QString _password;
    QString _httpauthuser;
    QString _httpauthpasswd;
    bool _ignoreSSLErrors;

    // Startup
    bool _autologin;
    bool _useAutologin;
    bool _useAllFeedsOnStartup;

    // Feeds
    bool _displayIcons;
    bool _whiteBackgroundOnIcons;

    // Item List
    int _feeditemsOrder;
    int _lengthOfTitle;
    bool _showExcerpt;
    int _lengthOfExcerpt;
    bool _displayLabels;

    // Items
    bool _autoMarkRead;
    bool _displayImages;
    bool _stripInvisibleImg;
    int _webviewFontSize;

    // Harmattan
    bool _whiteTheme;

    // Other
    bool _showAll;
};
#endif // SETTINGS_HH
