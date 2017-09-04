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
                        onClicked: pageStack.pop(aboutPage)
                        roomList.visible = true;
                    }
                }
            ]
        }
    }

    Column{
        spacing: units.gu(1)
        id:infoColumn
        width: parent.width

        anchors {
            fill: parent
            topMargin: header.flickable ? 0 : header.height
            centerIn: parent
        }

        UbuntuShape {
            width: units.gu(10)
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            source: Image {
                source: "../logo.png"
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {if(showDebug < 3){showDebug++}}
            }
        }

        Repeater {
            model: ListModel {
                ListElement {
                    text: "Author: Mikel Larrea.<br> Source Code: https://github.com/LarreaMikel/uMatriks <br> "
                }
                ListElement {
                    text: "Author: Josip Delic.<br> https://github.com/delijati <br> "
                }
                ListElement {
                    text: "Joan CiberSheep.<br> https://github.com/cibersheep <br> "
                }
                ListElement {
                    text: "Bjarne Roß.<br> https://github.com/nfsprodriver <br> "
                }
                ListElement {
                    text: "Marius Gripsgard. <br> https://github.com/mariogrip <br> "
                }
                ListElement {
                    text: "Not in your language? Please help us translating the app by contributing on: <br> https://poeditor.com/join/project/Og2UosRdlD <br><br> "
                }
                ListElement {
                    text: "This program uses libqmatrixclient<br> Copyright (C) 2015-2017 Felix Rohrbach kde@fxrh.de and others <br> #quaternion:matrix.org"
                }
                ListElement {
                    text: "https://github.com/QMatrixClient/libqmatrixclient"
                }
                ListElement {
                    text: "<br> <br> and modifies code from Tensor <br> #tensor:matrix.org"
                }
                ListElement {
                    text: "https://github.com/Quiark/tensor"
                }

                ListElement {
                    text: ""
                }
            }
            Label {
                width: parent.width
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text: Utils.checkForLink(model.text)
                onLinkActivated: Qt.openUrlExternally(link)
            }
        }
    }
}

