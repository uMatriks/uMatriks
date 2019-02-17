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
import Ubuntu.Components.Themes 1.3
import 'utils.js' as Utils

Page {
    id: aboutPage

    theme: ThemeSettings {
        name: uMatriks.theme.name
    }

    property int showDebug

    style: Rectangle {
        anchors.fill: parent
        color: uMatriks.theme.palette.normal.background
    }

    header: PageHeader {
        title: i18n.tr("About...")
        leadingActionBar {
            numberOfSlots: 1
            actions: [
                Action {
                    id: actionSettings
                    iconName: "back"
                    text: i18n.tr("Back")
                    shortcut: "Ctrl+B"
                    onTriggered: {
                        onClicked: mainAdaptiveLayout.removePages(aboutPage)
                    }
                }
            ]
        }
    }

    Flickable {
        id: flick
        anchors {
            fill: parent
            topMargin: header.height * 1.75
            centerIn: parent
        }

        contentWidth: aboutColumn.width
        contentHeight: aboutColumn.height + units.gu(15)

        Column{
            id: aboutColumn
            width: parent.parent.width
            spacing: units.gu(3)




            UbuntuShape {
                id: appLogo
                width: units.gu(12); height: units.gu(12)
                anchors.horizontalCenter: parent.horizontalCenter
                radius: "medium"
                image: Image {
                    source: settings.theme ? "./resources/logo-dark.png" : "./resources/logo.png"
                }
            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "<a href='https://github.com/uMatriks/uMatriks'>Source Code</a>"
                linkColor: darkColor
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: i18n.tr("Authors")
                fontSize: "large"
                font.bold: true
                color: uMatriks.theme.palette.normal.backgroundText
            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "<a href='https://github.com/LarreaMikel'>Mikel Larrea</a> (@larrea.mikel:matrix.org)"
                linkColor: darkColor
                onLinkActivated: Qt.openUrlExternally(link)
                color: uMatriks.theme.palette.normal.backgroundText
            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "<a href='https://github.com/delijati'>Josip Delic</a> (@delijati:matrix.org)"
                onLinkActivated: Qt.openUrlExternally(link)
                color: uMatriks.theme.palette.normal.backgroundText
            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "<a href='https://github.com/cibersheep'>Joan CiberSheep </a> (@cibersheep:matrix.org)"
                onLinkActivated: Qt.openUrlExternally(link)
                color: uMatriks.theme.palette.normal.backgroundText
            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "<a href='https://github.com/nfsprodriver'>Bjarne Roß </a> (@nfsprodriver:matrix.org)"
                onLinkActivated: Qt.openUrlExternally(link)
                color: uMatriks.theme.palette.normal.backgroundText
            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "<a href='https://github.com/mariogrip'>Marius Gripsgard </a> (@mariogrip:matrix.org)"
                onLinkActivated: Qt.openUrlExternally(link)
                color: uMatriks.theme.palette.normal.backgroundText
            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "<a href='https://github.com/thrrgilag'>Morgan McMillian </a> (@thrrgilag:monkeystew.net) "
                onLinkActivated: Qt.openUrlExternally(link)
                color: uMatriks.theme.palette.normal.backgroundText
            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: i18n.tr("Translations")
                fontSize: "large"
                font.bold: true
                color: uMatriks.theme.palette.normal.backgroundText
            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: i18n.tr("Not in your language? Please help us translating the app by contributing on: <a href='https://poeditor.com/join/project/4VSWHLQChQ'>poeditor</a> ")
                onLinkActivated: Qt.openUrlExternally(link)
                color: uMatriks.theme.palette.normal.backgroundText
            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: i18n.tr("Acknowledgement")
                fontSize: "large"
                font.bold: true
                color: uMatriks.theme.palette.normal.backgroundText
            }


            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "This program uses <a href='https://github.com/QMatrixClient/libqmatrixclient'>libqmatrixclient</a> <i>Copyright (C) 2015-2017 Felix Rohrbach kde@fxrh.de and others<i><b> #quaternion:matrix.org <b>"
                onLinkActivated: Qt.openUrlExternally(link)
                color: uMatriks.theme.palette.normal.backgroundText
            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "and modifies code from <a href='https://github.com/Quiark/tensor'>Tensor</a><b> #tensor:matrix.org <b>"
                onLinkActivated: Qt.openUrlExternally(link)
                color: uMatriks.theme.palette.normal.backgroundText
            }
        }
    }
}
