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


    Flickable {
        id: flick
        anchors {
            fill: parent
//            topMargin: header.flickable ? 0 : header.height
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
                    source: settings.theme ? "./logo-dark.png" : "./logo.png"        // LOGO DE LA APP
                }
            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "<a href='https://github.com/LarreaMikel/uMatriks'>Source Code</a>"
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
            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "<a href='https://github.com/LarreaMikel'>Mikel Larrea</a> (@larrea.mikel:matrix.org)"
                linkColor: darkColor
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "<a href='https://github.com/delijati'>Josip Delic</a> (@delijati:matrix.org)"
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "<a href='https://github.com/cibersheep'>Joan CiberSheep </a> (@cibersheep:matrix.org)"
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "<a href='https://github.com/nfsprodriver'>Bjarne Roß </a> (@nfsprodriver:matrix.org)"
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "<a href='https://github.com/mariogrip'>Marius Gripsgard </a> (@mariogrip:matrix.org)"
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "<a href='https://github.com/thrrgilag'>Morgan McMillian </a> (@thrrgilag:monkeystew.net) "
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: i18n.tr("Translations")
                fontSize: "large"
                font.bold: true
            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: i18n.tr("Not in your language? Please help us translating the app by contributing on: <a href='https://poeditor.com/join/project/Og2UosRdlD'>poeditor</a> ")
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: i18n.tr("Acknowledgement")
                fontSize: "large"
                font.bold: true
            }


            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "This program uses <a href='https://github.com/QMatrixClient/libqmatrixclient'>libqmatrixclient</a> <i>Copyright (C) 2015-2017 Felix Rohrbach kde@fxrh.de and others<i><b> #quaternion:matrix.org <b>"
                onLinkActivated: Qt.openUrlExternally(link)
            }
//            Label{
//                anchors.margins: units.gu(5)
//                width: parent.width
//                horizontalAlignment: Text.AlignHCenter
//                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
//                text: "https://github.com/QMatrixClient/libqmatrixclient"
//                onLinkActivated: Qt.openUrlExternally(link)
//            }

            Label{
                anchors.margins: units.gu(5)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "and modifies code from <a href='https://github.com/Quiark/tensor'>Tensor</a><b> #tensor:matrix.org <b>"
                onLinkActivated: Qt.openUrlExternally(link)
            }

//            Label{
//                anchors.margins: units.gu(5)
//                width: parent.width
//                horizontalAlignment: Text.AlignHCenter
//                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
//                text: "https://github.com/Quiark/tensor"
//                onLinkActivated: Qt.openUrlExternally(link)
//            }

//            Label {
//                width: parent.width
//                wrapMode: Text.Wrap
//                horizontalAlignment: Text.AlignHCenter
//                text: Utils.checkForLink(model.text)
//                onLinkActivated: Qt.openUrlExternally(link)
//            }



        }



    }

}


//    Column{
//        spacing: units.gu(1)
//        id:infoColumn
//        width: parent.width

//        anchors {
//            fill: parent
//            topMargin: header.flickable ? 0 : header.height
//            centerIn: parent
//        }

//        Image {
//            width: units.gu(10)
//            height: width
//            anchors.horizontalCenter: parent.horizontalCenter
//            source:  settings.theme ? "./logo-dark.png" : "./logo.png"
//        }

//        Repeater {
//            model: ListModel {
//                ListElement {
//                    text: "Author: Mikel Larrea.<br> Source Code: https://github.com/LarreaMikel/uMatriks <br> "
//                }
//                ListElement {
//                    text: "Author: Josip Delic.<br> https://github.com/delijati <br> "
//                }
//                ListElement {
//                    text: "Joan CiberSheep.<br> https://github.com/cibersheep <br> "
//                }
//                ListElement {
//                    text: "Bjarne Roß.<br> https://github.com/nfsprodriver <br> "
//                }
//                ListElement {
//                    text: "Marius Gripsgard. <br> https://github.com/mariogrip <br> "
//                }
//                ListElement {
//                    text: "Morgan McMillian. <br> https://github.com/thrrgilag <br> "
//                }
//                ListElement {
//                    text: "Not in your language? Please help us translating the app by contributing on: <br> https://poeditor.com/join/project/Og2UosRdlD <br><br> "
//                }
//                ListElement {
//                    text: "This program uses libqmatrixclient<br> Copyright (C) 2015-2017 Felix Rohrbach kde@fxrh.de and others <br> #quaternion:matrix.org"
//                }
//                ListElement {
//                    text: "https://github.com/QMatrixClient/libqmatrixclient"
//                }
//                ListElement {
//                    text: "<br> <br> and modifies code from Tensor <br> #tensor:matrix.org"
//                }
//                ListElement {
//                    text: "https://github.com/Quiark/tensor"
//                }

//                ListElement {
//                    text: ""
//                }
//            }
//            Label {
//                width: parent.width
//                wrapMode: Text.Wrap
//                horizontalAlignment: Text.AlignHCenter
//                text: Utils.checkForLink(model.text)
//                onLinkActivated: Qt.openUrlExternally(link)
//            }
//        }
//    }
//}

