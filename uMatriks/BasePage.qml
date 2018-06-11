import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Matrix 1.0


Page {
    id: basepage

    DialogJoinRoom {
        id: dialogJoinRoom
        property var current: null
        property Connection connection: null
    }

    header: PageHeader {
        id: pageHeader

        title: i18n.tr("[ uMatriks ]")
        leadingActionBar {
            numberOfSlots: 1
            actions: [
                Action {
                    iconName: "import"
                    text: i18n.tr("Join room")
                    onTriggered: {
                        console.log(dialogJoinRoom)
                        console.log(dialogJoinRoom.current)
                        dialogJoinRoom.connection = uMatriks.connection
                        // XXX we need to set a caller or popup will not ne shown
                        dialogJoinRoom.current = PopupUtils.open(dialogJoinRoom, uMatriks);
                    }
                },

                Action {
                    id: actionLogin
                    iconName: "system-log-out"
                    text: i18n.tr("Log out")
                    onTriggered: {
                        logout();
                        roomList.visible = false;
                        mainAdaptiveLayout.addPageToCurrentColumn(mainAdaptiveLayout.primaryPage,Qt.resolvedUrl("Login.qml"))
                    }
                },
                Action {
                    id: actionInfo
                    iconName: "info"
                    text: i18n.tr("About")
                    onTriggered: {
                        roomList.visible = false;
                        mainAdaptiveLayout.addPageToNextColumn(mainAdaptiveLayout.primaryPage,Qt.resolvedUrl("About.qml"))
                    }
                }
            ]
        }
        trailingActionBar {
            numberOfSlots: 2
            actions: [
                Action {
                    id: actionTheme
                    iconName: settings.theme ? "torch-off" : "torch-on"
                    onTriggered: {
                        settings.theme = !settings.theme
                    }
                }
            ]
        }
    }
}


