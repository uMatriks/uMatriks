import QtQuick 2.4
import Ubuntu.Components 1.3
//import Qt.labs.settings 1.0
import Matrix 1.0
import 'jschat.js' as JsChat



Rectangle {
//    color: Theme.roomListBg

    signal enterRoom(var room)
    signal joinRoom(string name)
//    signal leaveRoom(var room)

    property bool initialised: false
    property bool roomsUpdating: false

    RoomListModel {
        id: rooms

        onDataChanged: {
            // may have received a message but if focused, mark as read
            var room = currentRoom()
            if (room != null) room.markAllMessagesAsRead()

        }

    }

    function setConnection(conn) {
        rooms.setConnection(conn)
    }

    function init() {
        var defaultRoom = "#uMatriks:matrix.org"
        initialised = true
        var found = false
        for (var i = 0; i < rooms.rowCount(); i++) {
            if (rooms.roomAt(i).canonicalAlias === defaultRoom) {
                roomListView.currentIndex = i
                enterRoom(rooms.roomAt(i))
//                pageMain.visible = false;
//                mainPageStack.push(roomViewItem)
//                found = true
            }
        }
        if (!found) joinRoom(defaultRoom)
    }

    function refresh() {
        if(roomListView.visible)
            roomListView.forceLayout()
//        roomsUpdating = false
    }

    function changeRoom(dir) {
        roomListView.currentIndex = JsChat.posmod(roomListView.currentIndex + dir, roomListView.count);
        enterRoom(rooms.roomAt(roomListView.currentIndex))
        pageMain.visible = false;
        mainPageStack.push(roomViewItem)
    }

    function currentRoom() {
        if (roomListView.currentIndex < 0) return null
        var room = rooms.roomAt(roomListView.currentIndex)
        return room
    }

    Column {
        anchors.fill: parent

        ListView {
            id: roomListView
            model: rooms
            width: parent.width
            height: parent.height - textEntry.height
//            spacing: 5

            delegate: ListItem{
                height: roomListLayout.height + (divider.visible ? divider.height : 0)

                ListItemLayout{
                    id:roomListLayout
                    title.text: display
                    subtitle.text: "subtitle"


                    Rectangle {
                        SlotsLayout.position: SlotsLayout.Leading
//                        color: "grey"
                        height: units.gu(5)
                        width: height
                        border.width: parent.activeFocus ? 1 : 2
                        border.color: "black"
                        radius: width * 0.5
                        Text {
                            anchors{
                                horizontalCenter: parent.horizontalCenter
                                verticalCenter: parent.verticalCenter
                            }
                            font.bold: true
                            font.pointSize: units.gu(2)
                            text: qsTr(roomListLayout.title.text[0]+roomListLayout.title.text[1])

                        }

                    }

                    Label{
                        id: lastMessage
                        SlotsLayout.position: SlotsLayout.Trailing

                        text:"Last message "
                        fontSize: "small"
                    }

                }

                leadingActions: ListItemActions {
                    actions: [
                        Action {
                            iconName: "system-log-out" //change icon
                            text: i18n.tr("Leave")
                            onTriggered: {
                                var current = currentRoom(index)
                                if (current !== null){
                                    leaveRoom(current)
                                    refresh()
                                    console.log("Leaving " + display + " room");
                                }else{
                                    console.log("Unable to leave room: " + display)
                                }

                            }
                        },
                        Action {
                            iconName: "delete"
                            onTriggered: {
                            // the value will be undefined
                            console.log("Room deleted");
                            }
                        }
                    ]
                }
                trailingActions: ListItemActions {
                    actions: [
//                        Action {
//                            iconName: "system-log-out" //change icon
//                        },
                        Action {
                            iconName: "info" //change icon
                            onTriggered: {
                            // the value will be undefined
                            console.log("Show room info");
                            }
                        }
                    ]
                }
                onClicked: {
                    console.log("Room clicked. Entering: " + display + " room.")
                    roomListView.currentIndex = index
                    enterRoom(rooms.roomAt(index))
                    pageMain.visible = false;
                    mainPageStack.push(roomViewItem)

                }


            }

            highlight: Rectangle {
                height: 20
                radius: 2
//                color: Theme.roomListSelectedBg
                color: "#9c27b0"
            }
            highlightMoveDuration: 0

            onCountChanged: if(initialised) {
                roomListView.currentIndex = count-1
                enterRoom(rooms.roomAt(count-1))
// Commenting this two lines the first page to load will be the roomlist.
//                pageMain.visible = false;
//                mainPageStack.push(roomViewItem)
            }


            PullToRefresh{
                refreshing: roomsUpdating
                onRefresh: {
//                    roomsUpdating = true
//                    refresh()
                    console.log("room updated");

                }
            }




        }

        TextField {
            id: textEntry
            width: parent.width
            placeholderText: qsTr("Join room...")
            onAccepted: { joinRoom(text); text = "" }
        }
    }
}
