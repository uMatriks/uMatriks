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
import Matrix 1.0
import 'utils.js' as Utils
import Ubuntu.Components.Popups 1.3
import "components"

BasePage {
    id: roomList
    title: i18n.tr("RoomList")
    visible: false
    clip:true

    RoomListModel {
        id: rooms

        onRoomDataChangedEvent: {
            // XXX used for updating unread marker
            var room  = rooms.roomAt(index)
            console.log("Event for: %1".arg(room.displayName))
            roomListView.contentItem.children[index].refreshUnread()
        }
    }

    function setConnection(conn) {
        rooms.addConnection(conn)
        roomView.setConnection(conn)
    }

    function init(connection) {
        setConnection(connection)
        for(var child in roomListView.contentItem.children) {
           roomListView.contentItem.children[child].refreshUnread()
        }
    }

    function refresh() {
        if(roomListView.visible)
            roomListView.forceLayout();
    }

    function getUnread(index) {
        return rooms.roomAt(index).hasUnreadMessages
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
                uMatriks.roomListComplete = true
                uMatriks.componentsComplete();
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
                    unread = getUnread(index)
                    number = getNumber(index)
                    // console.log("[%1] %2 unread: %3 number: %4".arg(index).arg(display).arg(unread).arg(number))
                }

                ListItemLayout{
                    id: roomListLayout
                    title.text: display
                    title.font.bold: unread
                    title.color: uMatriks.theme.palette.normal.backgroundText
                    summary.text: lastEvent

                    Rectangle {
                        SlotsLayout.position: SlotsLayout.Leading
                        height: units.gu(5)
                        width: height
                        color: uMatriks.theme.palette.normal.background

                        Avatar {
                            id: roomAvatar
                            anchors.fill: parent
                            source: roomImg
                            user: display
                        }
                    }

                     Rectangle {
                         SlotsLayout.position: SlotsLayout.Trailing
                         color: "grey"
                         height: units.gu(2.3)
                         width: height
                         visible: unread && unreadCount > 0
                         radius: width * 0.5
                         Text {
                             anchors{
                                 horizontalCenter: parent.horizontalCenter
                                 verticalCenter: parent.verticalCenter
                             }
                             font.pointSize: unreadCount < 100 ? units.gu(1) : units.gu(0.7)
                             text: unreadCount
                             color: "white"
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
                                memberList.members = rooms.roomAt(index).memberNames
                                memberList.title = i18n.tr("Members of ")
                                memberList.title += rooms.roomAt(index).displayName
                                mainAdaptiveLayout.addPageToNextColumn(mainAdaptiveLayout.primaryPage, memberList)

                            }
                        }
                    ]
                }

                onClicked: {
                    console.log("Room clicked. Entering: " + display + " room.")
                    uMatriks.activeRoomIndex = index
                    roomListView.currentIndex = index
                    roomView.setRoom(rooms.roomAt(index))
                    //roomList.visible = false;
                    mainAdaptiveLayout.addPageToNextColumn(mainAdaptiveLayout.primaryPage, roomView)
                    roomListView.contentItem.children[index].refreshUnread()
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
