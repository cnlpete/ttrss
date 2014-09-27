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

#ifndef QMLUTILS_HH
#define QMLUTILS_HH

#include <QtCore/QObject>
#include <QtCore/QVariant>
#include <QtCore/QScopedPointer>

class QMLUtils : public QObject
{
    Q_OBJECT
public:
    static QMLUtils *instance();

    // Share a link using Harmattan Share UI
    Q_INVOKABLE void share(const QString &link, const QString &title = QString());

private:
    static QScopedPointer<QMLUtils> m_instance;

    explicit QMLUtils(QObject *parent = 0);
    Q_DISABLE_COPY(QMLUtils)
};

#endif // QMLUTILS_HH
