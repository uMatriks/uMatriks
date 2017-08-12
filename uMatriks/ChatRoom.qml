import QtQuick 2.4
import Ubuntu.Components 1.3
import Matrix 1.0
import "components"
//import Qt.labs.settings 1.0
//import 'jschat.js' as JsChat


Rectangle {
    id: root

    property Connection currentConnection: null
    property var currentRoom: null
    property string status: ""


    function setRoom(room) {
        currentRoom = room
        messageModel.changeRoom(room)
        room.markAllMessagesAsRead()
        chatView.positionViewAtBeginning()
    }

    function setConnection(conn) {
        currentConnection = conn
        messageModel.setConnection(conn)
    }

    function sendLine(text) {
        if(!currentRoom || !currentConnection) return
        currentConnection.postMessage(currentRoom, "m.text", text)
        chatView.positionViewAtBeginning()
    }

    function scrollPage(amount) {
        scrollBar.position = Math.max(0, Math.min(1 - scrollBar.size, scrollBar.position + amount * scrollBar.stepSize));
    }


    ListView {
        id: chatView
        anchors.fill: parent
        flickableDirection: Flickable.VerticalFlick
        verticalLayoutDirection: ListView.BottomToTop
        spacing: units.gu(1)
        model: MessageEventModel { id: messageModel }


        delegate: ChatBubble {
            id: chatBubble
            width: parent.width
            room: currentRoom
        }


        /*
        section {
            property: "date"
            labelPositioning: ViewSection.CurrentLabelAtStart
            delegate: Rectangle {
                id: dateRect
                width: parent.width
                height: childrenRect.height
                anchors.top: chatBubble.bottom
                Label {
                    width: parent.width
                    text: status + " " + section.toLocaleString(Qt.locale())
                    color: "grey"
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
        */

        onAtYBeginningChanged: {
            if(currentRoom && atYBeginning) currentRoom.getPreviousContent(50)
        }

        Scrollbar {
            id: scrollBar
            align: Qt.AlignTrailing
        }

    }
}
