#ifndef SETTINGS_HH
#define SETTINGS_HH

#include <QtCore/QObject>
#include <QtCore/QScopedPointer>
#include <QtCore/qstring.h>

class QSettings;

class Settings : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString servername READ servername WRITE setServername NOTIFY servernameChanged)
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
    Q_PROPERTY(bool autologin READ hasAutologin WRITE setAutologin NOTIFY autologinChanged)
    Q_PROPERTY(bool useAutologin READ hasUseAutologin WRITE setUseAutologin NOTIFY useAutologinChanged)

    Q_PROPERTY(QString httpauthusername READ httpauthUsername WRITE setHttpauthUsername NOTIFY httpauthUsernameChanged)
    Q_PROPERTY(QString httpauthpassword READ httpauthPassword WRITE setHttpauthPassword NOTIFY httpauthPasswordChanged)

    Q_PROPERTY(bool whiteTheme READ isWhiteTheme WRITE setWhiteTheme NOTIFY whiteThemeChanged)
    Q_PROPERTY(int feeditemsOrder READ feeditemsOrder WRITE setFeeditemsOrder NOTIFY feeditemsOrderChanged)
    Q_PROPERTY(bool displayIcons READ displayIcons WRITE setDisplayIcons NOTIFY displayIconsChanged)
    Q_PROPERTY(int webviewFontSize READ webviewFontSize WRITE setWebviewFontSize NOTIFY webviewFontSizeChanged)
    Q_PROPERTY(bool autoMarkRead READ autoMarkRead WRITE setAutoMarkRead NOTIFY autoMarkReadChanged)
    Q_PROPERTY(bool useAllFeedsOnStartup READ useAllFeedsOnStartup WRITE setUseAllFeedsOnStartup NOTIFY useAllFeedsOnStartupChanged)
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

    bool hasAutologin() const {
        return this->_autologin;
    }
    void setAutologin(bool autologin);

    bool hasUseAutologin() const {
        return this->_useAutologin;
    }
    void setUseAutologin(bool useAutologin);

    QString httpauthUsername() const {
        return this->_httpauthuser;
    }
    void setHttpauthUsername(QString username);

    QString httpauthPassword() const {
        return this->_httpauthpasswd;
    }
    void setHttpauthPassword(QString password);

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

signals:
    void servernameChanged();
    void usernameChanged();
    void passwordChanged();
    void autologinChanged();
    void useAutologinChanged();

    void httpauthUsernameChanged();
    void httpauthPasswordChanged();

    void whiteThemeChanged();
    void feeditemsOrderChanged();
    void displayIconsChanged();
    void webviewFontSizeChanged();
    void autoMarkReadChanged();
    void useAllFeedsOnStartupChanged();

private:
    static QScopedPointer<Settings> m_instance;

    explicit Settings(QObject *parent = 0);
    Q_DISABLE_COPY(Settings)

    QSettings *m_settings;

    QString _servername;
    QString _username;
    QString _password;
    bool _autologin;
    bool _useAutologin;

    QString _httpauthuser;
    QString _httpauthpasswd;

    bool _whiteTheme;
    int _feeditemsOrder;
    bool _displayIcons;
    int _webviewFontSize;
    bool _autoMarkRead;
    bool _useAllFeedsOnStartup;
};
#endif // SETTINGS_HH
