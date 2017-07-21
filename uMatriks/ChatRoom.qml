import QtQuick 2.4
import Ubuntu.Components 1.3
import Matrix 1.0
//import Qt.labs.settings 1.0
import 'jschat.js' as JsChat


Rectangle {
    id: root
//    color: Theme.chatBg
//    color: "#fdf6e3"

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
        model: MessageEventModel { id: messageModel }

        delegate: Row {
            id: message
            width: parent.width
            spacing: 8

//            Image{
//                source: "logo.png"
////                source: eventType == "message" ? author: avatar
//                width: units.gu(3)
//                height: units.gu(3)

//            }

            Column{
                Label {
                    id: timelabel
                    text: time.toLocaleTimeString("hh:mm")
                    color: "grey"
                    width: units.gu(6)
                    //                font.pointSize: Theme.timeLabelSize
                    font.pointSize: units.gu(0.9)
                    horizontalAlignment: Text.AlignRight
                }
                Label {
                    id: authorlabel
                    width: units.gu(6)
                    elide: Text.ElideRight
                    text: eventType == "message" ? author : "***"
                    //                font.family: Theme.nickFont
                    font.family: "Consolas"
                    font.pointSize: units.gu(0.9)
                    color: eventType == "message" ? JsChat.NickColoring.get(author): "lightgrey"
                    horizontalAlignment: Text.AlignRight
                }
            }
            Label {
                id: contentlabel
                text: content
                wrapMode: Text.Wrap
                width: parent.width - (x - parent.x) - spacing
                color: eventType == "message" ? "black" : "lightgrey"
                linkColor: "black"
                textFormat: Text.RichText
//                font.family: Theme.textFont
                font.family:"Ubuntumono"
//                font.pointSize: Theme.textSize
                font.pointSize: units.gu(1.5)
                onLinkActivated: Qt.openUrlExternally(link)
            }
        }


        section {
            property: "date"
            labelPositioning: ViewSection.CurrentLabelAtStart
            delegate: Rectangle {
                width: parent.width
                height: childrenRect.height
                //color: Theme.chatBg
//                color: "#fdf6e3"
                Label {
                    width: parent.width
                    text: status + " " + section.toLocaleString(Qt.locale())
                    color: "grey"
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        onAtYBeginningChanged: {
            if(currentRoom && atYBeginning) currentRoom.getPreviousContent(50)
        }

//        ScrollBar.vertical: ScrollBar {
        Scrollbar {
            id: scrollBar
//            stepSize: chatView.visibleArea.heightRatio / 3
            align: Qt.AlignTrailing
        }


    }
}
