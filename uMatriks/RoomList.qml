import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.3
import Matrix 1.0
import 'utils.js' as Utils
import Ubuntu.Components.Popups 1.3


BasePage {
    id: roomList
    title: i18n.tr("RoomList")
    visible: false

    property bool initialised: false

    RoomListModel {
        id: rooms

        onDataChanged: {
            // may have received a message but if focused, mark as read
            console.log("********************* Event..." + index)
            var room  = rooms.roomAt(index)
            console.log(room.displayName + " : " + room.hasUnreadMessages() + " -> "+ room.notificationCount())
            if(initialised) {
                for (var i = 0; i < rooms.rowCount(); i++) {
                    roomListView.currentIndex = i
                    roomListView.currentItem.refreshUnread()
                }
            }
        }
    }

    function setConnection(conn) {
        rooms.setConnection(conn)
        roomView.setConnection(conn)
    }

    function init(connection) {
        setConnection(connection)
        var defaultRoom = "#uMatriks:matrix.org"
        initialised = true
        var found = false
        for (var i = 0; i < rooms.rowCount(); i++) {
            if (rooms.roomAt(i).canonicalAlias === defaultRoom) {
                roomListView.currentIndex = i
                roomListView.currentItem.refreshUnread()
            }
        }
        if (!found) connection.joinRoom(defaultRoom)
    }

    function refresh() {
        if(roomListView.visible)
        roomListView.forceLayout()
    }

    function getUnread(index) {
        return rooms.roomAt(index).hasUnreadMessages()
    }

    function getNumber(index) {
        return rooms.roomAt(index).notificationCount()
    }

    Column {
        anchors {
            fill: parent
            topMargin: header.flickable ? 0 : header.height
        }

        ListView {
            id: roomListView
            model: rooms
            width: parent.width
            height: parent.height

            Component.onCompleted: {
                visible = true;
            }

            delegate: ListItem{
                id: helpId

                theme: ThemeSettings {
                    name: uMatriks.theme.name
                }

                height: roomListLayout.height + (divider.visible ? divider.height : 0)
                property bool unread: false
                property int number: 0
                function refreshUnread() {
                    //console.log("Running..." + index)
                    var i = index
                    if(getUnread(i) !== unread || getNumber(i) !== number)
                    {
                        unread = getUnread(i)
                        number = getNumber(i)
                        console.log(display + unread + number)
                    }
                }

                ListItemLayout{
                    id: roomListLayout
                    title.text: display
                    title.font.bold: unread
                    title.color: uMatriks.theme.palette.normal.backgroundText

                    Rectangle {
                        SlotsLayout.position: SlotsLayout.Leading
                        height: units.gu(5)
                        width: height
                        border.width: parent.activeFocus ? 1 : 2
                        border.color: uMatriks.theme.palette.normal.backgroundText
                        color: uMatriks.theme.palette.normal.background
                        radius: width * 0.5
                        Text {
                            anchors{
                                horizontalCenter: parent.horizontalCenter
                                verticalCenter: parent.verticalCenter
                            }
                            font.bold: true
                            font.pointSize: units.gu(2)
                            text: roomListLayout.title.text[0]+roomListLayout.title.text[1]
                            color: uMatriks.theme.palette.normal.backgroundText

                        }

                    }

                    Rectangle {
                        SlotsLayout.position: SlotsLayout.Trailing
                        //                        color: "grey"
                        height: units.gu(3)
                        width: height
                        border.width: parent.activeFocus ? 0.5 : 1
                        border.color: "black"
                        color: UbuntuColors.green
                        visible: helpId.unread
                        radius: width * 0.5
                        Text {
                            anchors{
                                horizontalCenter: parent.horizontalCenter
                                verticalCenter: parent.verticalCenter
                            }
                            font.pointSize: helpId.number < 100 ? units.gu(1.5) : units.gu(1.1)
                            text: helpId.number
                        }

                    }
                }

                leadingActions: ListItemActions {
                    actions: [
                        Action {
                            iconName: "system-log-out" //change icon
                            text: i18n.tr("Leave")
                            onTriggered: {
                                var current = rooms.roomAt(index)
                                if (current !== null){
                                    leaveRoom(current)
                                    refresh()
                                    console.log("Leaving " + display + " room");
                                }else{
                                    console.log("Unable to leave room: " + display)
                                }
                            }
                        }
                    ]
                }
                trailingActions: ListItemActions {
                    actions: [
                        Action {
                            iconName: "info" //change icon
                            onTriggered: {
                                // the value will be undefined
                                console.log("Show room info: " + rooms.roomAt(index).topic );
                                var popup = PopupUtils.open(roomTopicDialog);
                                popup.description = Utils.checkForLink(rooms.roomAt(index).topic);
                            }
                        },
                        Action {
                            iconName: "account" //change icon
                            onTriggered: {
                                // the value will be undefined
                                console.log("Show member list: " + rooms.roomAt(index).displayName);
                                memberList.members = rooms.roomAt(index).memberNames()
                                roomList.visible = false
                                memberList.title = i18n.tr("Members of ")
                                memberList.title += rooms.roomAt(index).displayName
                                roomList.visible = false;
                                pageStack.push(memberList)

                            }
                        }
                    ]
                }

                onClicked: {
                    console.log("Room clicked. Entering: " + display + " room.")
                    uMatriks.activeRoomIndex = index
                    roomListView.currentIndex = index
                    roomView.setRoom(rooms.roomAt(index))
                    roomList.visible = false;
                    pageStack.push(roomView)
                }
            }
        }
    }

    Component {
        id: roomTopicDialog

        Dialog {
            id: dialogInternal

            property string description

            title: "<b>%1</b>".arg(i18n.tr("Room Topic"))

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                linkColor: "Blue"
                text: dialogInternal.description
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Button {
                text: i18n.tr("Close")
                onClicked: {
                    PopupUtils.close(dialogInternal)
                }
            }
        }
    }
}
