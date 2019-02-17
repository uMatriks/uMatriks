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
import Matrix 1.0
import "components"

Rectangle {
    id: root

    property Connection currentConnection: null
    property var currentRoom: null

    function setRoom(room) {
        currentRoom = room
        messageModel.changeRoom(room)
        // console.log("ChatRoom setting room: "+ room.name)
        room.markAllMessagesAsRead()
        chatView.positionViewAtIndex(room.notificationCount() - 1, ListView.Beginning)
    }

    function setConnection(conn) {
        currentConnection = conn
    }

    function sendLine(text) {
        // console.log("Sending: " + text)
        // console.log("Room: " + currentRoom)
        // console.log("Conn: " + currentConnection)
        if (text.trim().length === 0) {
            return
        }
        if(!currentRoom || !currentConnection) {
            return
        }

        // TODO lib expects postMessage(text,MsgType::Emote); :/
        // var PREFIX_ME = '/me '
        // if (text.indexOf(PREFIX_ME) === 0) {
        //     text = text.substr(PREFIX_ME.length)
        //     type = "m.emote"
        //     currentRoom.postMessage(text, type)
        // }

        currentRoom.postPlainText(text)
        chatView.positionViewAtBeginning()
    }

    ListView {
        id: chatView
        anchors.fill: parent
        flickableDirection: Flickable.VerticalFlick
        verticalLayoutDirection: ListView.BottomToTop
        spacing: units.gu(2)
        model: MessageEventModel { id: messageModel }

        delegate: ChatItem {
            id: chatBubble
            width: parent.width
            room: currentRoom
            connection: currentConnection
        }

        onAtYBeginningChanged: {
            if(currentRoom && atYBeginning) currentRoom.getPreviousContent(50)
        }

        Scrollbar {
            id: scrollBar
            align: Qt.AlignTrailing
        }
    }
}
