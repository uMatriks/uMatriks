import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.3

Page {
    id: aboutPage

    property int showDebug

    theme: ThemeSettings {
        name: "Ubuntu.Components.Themes.SuruDark"
        palette: Palette {
            normal.background: UbuntuColors.slate
        }
    }
    style: Rectangle {
        anchors.fill: parent
        color: theme.palette.normal.background
    }
    header: PageHeader {
        title: i18n.tr("About...")
        StyleHints {
            foregroundColor: UbuntuColors.jet
            backgroundColor: UbuntuColors.silk
            dividerColor: UbuntuColors.warmGrey
        }
        leadingActionBar {
            numberOfSlots: 1
            actions: [
                Action {
                    id: actionSettings
                    iconName: "back"
                    text: i18n.tr("Back")
                    shortcut: "Ctrl+B"
                    onTriggered: {
                        onClicked: mainPageStack.pop(aboutPage)
                        pageMain.visible = true;
                    }
                }
            ]
        }

    }

    Column{
        spacing: units.gu(1)
        id:infoColumn
        width: parent.width
        anchors.centerIn: parent


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
                    text: "Author: Mikel Larrea.\n Source Code: https://github.com/LarreaMikel/uMatriks \n "
                }
                ListElement {
                    text: "Joan CiberSheep.\n https://github.com/cibersheep \n "
                }
                ListElement {
                    text: "Bjarne Roß.\n https://github.com/nfsprodriver \n "
                }
                ListElement {
                    text: "Marius Gripsgard.\n https://github.com/mariogrip \n\n "
                }
                ListElement {
                    text: "This program uses libqmatrixclient\n Copyright (C) 2015-2017 Felix Rohrbach kde@fxrh.de and others \n #quaternion:matrix.org"
                }
                ListElement {
                    text: "https://github.com/QMatrixClient/libqmatrixclient"
//                    text: i18n.tr("Source code available on %1").arg("<a href=\"https://github.com/QMatrixClient/libqmatrixclient\">link</a>")
                }
                ListElement {
                    text: "\n \n and modifies code from Tensor \n #tensor:matrix.org"
                }
                ListElement {
                    text: "https://github.com/Quiark/tensor"
//                    text: i18n.tr("Source code available on %1").arg("<a href=\"https://github.com/Quiark/tensor\">link</a>")
                }

                ListElement {
                    text: ""
                }


            }
            Label {
                width: parent.width
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text: model.text
            }
        }



        Button{
            text: i18n.tr("Share Debug Logs")
            visible: showDebug > 2
            anchors{ horizontalCenter: parent.horizontalCenter }
            //                        onClicked: apl.addPageToNextColumn(apl.primaryPage, Qt.resolvedUrl("SharePage.qml"), {transferItems: owncloudsync.logPath()})
            onClicked: console.log("Creating logfile.")
        }
    }


}

