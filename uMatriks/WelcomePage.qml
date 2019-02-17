/*
This file is part of uMatriks.

uMatriks is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

uMatriks is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with uMatriks.  If not, see <https://www.gnu.org/licenses/>.
*/

import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id:page
    property int pagenumber

    Component.onCompleted: setPage (0)

    Column{
        id: introductionPage
        anchors.fill: parent
        anchors.margin: units.gu(2)
        spacing: units.gu(2)
        Label{
            width: parent.width
            wrapMode: Text.Wrap
            text: i18n.tr ("Welcome to uMatriks!<br/>\
            <br/>\
            uMatriks is a program that allows you to use the Matrix network.")
        }
    }

    Column{
        id: identityPage
        visible: false
        anchors.fill: parent
        anchors.margin: units.gu(2)
        spacing: units.gu(2)

        Label{
            width: parent.width
            wrapMode: Text.Wrap
            text: i18n.tr ("To use uMatriks, you need to login with your matrix <i>user</i>.")
        }

        Label{
            width: parent.width
            wrapMode: Text.Wrap
            text: i18n.tr ("Matrix ID:")
        }

        TextField {
            width: parent.width
            id: userNameFieldkk
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            validator: RegExpValidator { regExp: /[A-Za-z][A-Za-z0-9\[\]\\`_\-^{|}]*/ }
            // TRANSLATORS: Example nickname
            placeholderText: i18n.tr ("chattyman")
        }
    }
}
