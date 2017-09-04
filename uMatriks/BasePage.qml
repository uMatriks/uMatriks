import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3


Page {
    id: basepage

    DialogJoinRoom {
        id: dialogJoinRoom
        property var current: null
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
                        pageStack.push(Qt.resolvedUrl("Login.qml"))
                    }
                },
                Action {
                    id: actionInfo
                    iconName: "info"
                    text: i18n.tr("About")
                    onTriggered: {
                        roomList.visible = false;
                        pageStack.push(Qt.resolvedUrl("About.qml"))
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
                },
                Action {
                    id: actionScan
                    iconName: settings.devScan ? "transfer-progress" : "transfer-none"
                    onTriggered: {
                        settings.devScan = !settings.devScan
                        var popup = PopupUtils.open(warning, roomList);
                        if (settings.devScan) popup.description = i18n.tr("This will activate a test function, which lets you see the amount of unread messages for each room. Please report bugs. Restart the app so the changes take effect.")
                        else popup.description = i18n.tr("Deactivated test function. Please restart the app so the changes take effect.")
                    }
                }

            ]
        }
    }
}


