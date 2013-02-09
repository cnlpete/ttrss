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

    Q_PROPERTY(bool whiteTheme READ isWhiteTheme WRITE setWhiteTheme NOTIFY whiteThemeChanged)
public:
    static Settings *instance();

    QString servername() const {
        QString s("returning ");
        s += this->_servername;
        s += " for servername req";
        qDebug(s.toStdString().c_str());
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

    bool isWhiteTheme() const {
        return this->_whiteTheme;
    }
    void setWhiteTheme(bool whiteTheme);

signals:
    void servernameChanged();
    void usernameChanged();
    void passwordChanged();
    void autologinChanged();

    void whiteThemeChanged();

private:
    static QScopedPointer<Settings> m_instance;

    explicit Settings(QObject *parent = 0);
    Q_DISABLE_COPY(Settings)

    QSettings *m_settings;

    QString _servername;
    QString _username;
    QString _password;
    bool _autologin;

    bool _whiteTheme;
};
#endif // SETTINGS_HH
