import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.3
//import Qt.labs.settings 1.0
import Matrix 1.0
import 'jschat.js' as JsChat
import Ubuntu.Components.Popups 1.3



Rectangle {
    //    color: Theme.roomListBg


    signal enterRoom(var room)
    signal joinRoom(string name)
    //    signal leaveRoom(var room)

    property bool initialised: false
    property bool roomsUpdating: false
    property bool globalTrigger: false

    RoomListModel {
        id: rooms

        onDataChanged: {
            // may have received a message but if focused, mark as read
            console.log("Event...")
            if(initialised) {
                globalTrigger = true
                for (var i = 0; i < rooms.rowCount(); i++) {
                    roomListView.currentIndex = i
                    roomListView.currentItem.refreshUnread()
                }
            }
        }

    }

    function setConnection(conn) {
        rooms.setConnection(conn)
    }

    function getUnread(index) {
        return rooms.roomAt(index).hasUnreadMessages()
    }

    function getNumber(index) {
        return rooms.roomAt(index).notificationCount()
    }

    function scan() {
        function Timer() {
            return Qt.createQmlObject("import QtQuick 2.4; Timer {}", rooms);
        }
        var currentIndex = 0
        for (var i = 0; i < rooms.rowCount(); i++) {
            roomListView.currentIndex = i
            roomListView.currentItem.refreshUnread()
        }
        var counter = 0
        var speedTrigger = false
        var timer = new Timer();
        timer.interval = 300;
        timer.repeat = true;
        timer.triggered.connect(function()
        {
            var savedPos = roomListView.contentY
            roomListView.currentIndex = currentIndex
            roomListView.currentItem.refreshUnread()
            roomListView.contentY = savedPos
            if (uMatriks.activeRoomIndex !== -1) rooms.roomAt(uMatriks.activeRoomIndex).markAllMessagesAsRead()
            if (currentIndex !== (rooms.rowCount() - 1)) currentIndex++
            else currentIndex = 0
            //            if (globalTrigger)
            //            {
            //                globalTrigger = false
            //                speedTrigger = true
            //            }
            //            if(speedTrigger === true)
            //            {
            //                timer.interval = 1000 / rooms.rowCount()
            //                if (counter < 15 * rooms.rowCount()) counter++
            //                else {
            //                    counter = 0
            //                    speedTrigger = false
            //                    timer.interval = 3000 / rooms.rowCount()
            //                }
            //            }
        })

        timer.start();
    }

    function init() {
        var defaultRoom = "#uMatriks:matrix.org"
        initialised = true
        var found = false
        for (var i = 0; i < rooms.rowCount(); i++) {
            if (rooms.roomAt(i).canonicalAlias === defaultRoom) {
                roomListView.currentIndex = i
                enterRoom(rooms.roomAt(i))
            }
        }
        if (!found) joinRoom(defaultRoom)
        scan()
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
        id: roomListColumn
        visible: true
        anchors.fill: parent

        ListView {
            id: roomListView
            model: rooms
            width: parent.width
            height: parent.height - textEntry.height

            delegate: ListItem{
                id: helpId

                theme: ThemeSettings {
                    name: uMatriks.theme.name
                }

                height: roomListLayout.height + (divider.visible ? divider.height : 0)
                property bool unread: false
                property int number: 0
                function refreshUnread ()
                {
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
                    id:roomListLayout
                    title.text: display
                    title.color: uMatriks.theme.palette.normal.backgroundText
                    //                    subtitle.text: "subtitle"


                    Rectangle {
                        SlotsLayout.position: SlotsLayout.Leading
                        //                        color: "grey"
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
                        color: UbuntuColors.red
                        visible: helpId.unread
                        radius: width * 0.5
                        Text {
                            anchors{
                                horizontalCenter: parent.horizontalCenter
                                verticalCenter: parent.verticalCenter
                            }
                            font.pointSize: units.gu(1.5)
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
                                var popup = PopupUtils.open(roomTopicDialog, roomListItem);
                                popup.description = uMatriks.checkForLink(rooms.roomAt(index).topic);

                            }
                        },
                        Action {
                            iconName: "account" //change icon
                            onTriggered: {
                                // the value will be undefined
                                console.log("Show member list: " + rooms.roomAt(index).displayName);
                                memberListItem.members = rooms.roomAt(index).memberNames()
                                pageMain.visible = false
                                memberListItem.header.title = i18n.tr("Members of ")
                                memberListItem.header.title += rooms.roomAt(index).displayName
                                pageMain.visible = false;
                                mainPageStack.push(memberListItem)

                            }
                        }
                    ]
                }
                onClicked: {
                    console.log("Room clicked. Entering: " + display + " room.")
                    uMatriks.activeRoomIndex = index
                    roomListView.currentIndex = index
                    enterRoom(rooms.roomAt(index))
                    pageMain.visible = false;
                    mainPageStack.push(roomViewItem)

                }
            }

            highlightFollowsCurrentItem: false

        }

        TextField {
            id: textEntry
            width: parent.width
            placeholderText: qsTr("Join room...")
            onAccepted: { joinRoom(text); text = "" }
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
