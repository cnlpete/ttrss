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

#include "theme.hh"

QScopedPointer<Theme> Theme::m_instance(0);

Theme *Theme::instance() {
    if (m_instance.isNull())
        m_instance.reset(new Theme);

    return m_instance.data();
}

Theme::Theme(QObject *parent) : QObject(parent) { }

int Theme::fontSizeTiny() const {
    return 18; }
int Theme::fontSizeExtraSmall() const {
    return 20; }
int Theme::fontSizeSmall() const {
    return 22; }
int Theme::fontSizeMedium() const {
    return 24; }
int Theme::fontSizeLarge() const {
    return 26; }
int Theme::fontSizeExtraLarge() const {
    return 30; }
int Theme::fontSizeHuge() const {
    return 34; }

int Theme::paddingSmall() const {
    return 6; }
int Theme::paddingMedium() const {
    return 8; }
int Theme::paddingLarge() const {
    return 10; }
