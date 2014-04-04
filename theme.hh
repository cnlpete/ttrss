#ifndef THEME_HH
#define THEME_HH

#include <QtCore/QObject>

class Theme : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int fontSizeTiny READ fontSizeTiny NOTIFY themeChanged)
    Q_PROPERTY(int fontSizeExtraSmall READ fontSizeExtraSmall NOTIFY themeChanged)
    Q_PROPERTY(int fontSizeSmall READ fontSizeSmall NOTIFY themeChanged)
    Q_PROPERTY(int fontSizeMedium READ fontSizeMedium NOTIFY themeChanged)
    Q_PROPERTY(int fontSizeLarge READ fontSizeLarge NOTIFY themeChanged)
    Q_PROPERTY(int fontSizeExtraLarge READ fontSizeExtraLarge NOTIFY themeChanged)
    Q_PROPERTY(int fontSizeHuge READ fontSizeHuge NOTIFY themeChanged)

    Q_PROPERTY(int paddingSmall READ paddingSmall NOTIFY themeChanged)
    Q_PROPERTY(int paddingMedium READ paddingMedium NOTIFY themeChanged)
    Q_PROPERTY(int paddingLarge READ paddingLarge NOTIFY themeChanged)
public:
    static Theme *instance();

    int fontSizeTiny() const;
    int fontSizeExtraSmall() const;
    int fontSizeSmall() const;
    int fontSizeMedium() const;
    int fontSizeLarge() const;
    int fontSizeExtraLarge() const;
    int fontSizeHuge() const;

    int paddingSmall() const;
    int paddingMedium() const;
    int paddingLarge() const;

signals:
    void themeChanged();

private:
    static QScopedPointer<Theme> m_instance;

    explicit Theme(QObject *parent = 0);
    Q_DISABLE_COPY(Theme)

};

#endif // THEME_HH
