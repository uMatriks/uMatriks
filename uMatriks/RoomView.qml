import QtQuick 2.4
import QtGraphicalEffects 1.0
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.3
import Qt.labs.settings 1.0

Page {
    id: roomView
    title: i18n.tr("Room")
    visible: false
    clip:true

    property var currentRoom
    property var completion

    header: PageHeader {
       id:_pageHeader
       title: roomView.title
       leadingActionBar.actions: [
           Action {
               iconName: "back"
               text: "Back"
               onTriggered: mainAdaptiveLayout.removePages(roomView)
           }
       ]
    }

    function setRoom(room) {
        console.log("RoomView setting room: "+ room.name)
        _pageHeader.title = room.name

        currentRoom = room
        chat.setRoom(room)
    }

    function setConnection(conn) {
        chat.setConnection(conn)
    }

    function sendLine(line) {
        chat.sendLine(line)
        textEntry.text = ''
    }

    ChatRoom {
        id: chat
        anchors.bottom: textRect.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: {
            bottom: 20
        }

        color: uMatriks.theme.palette.normal.background
    }
    DropShadow {
       anchors.fill: textRect
       verticalOffset: -1
       radius:1
       samples: 3
       color: uMatriks.theme.palette.normal.base
       opacity: 0.5
       source:textRect
       transparentBorder :true
   }
    Rectangle {
        id: textRect
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        color: uMatriks.theme.palette.normal.background
        height:textRectRow.height + (textRectRow.anchors.margins * 2)
        Row {
            id:textRectRow

            anchors.right: parent.right
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: units.gu(1)

            spacing:units.gu(1)

            TextField {
                id: textEntry
                focus: true
                width: parent.width - sendBut.width - parent.anchors.margins
                placeholderText: qsTr("Say something...")
                onAccepted: sendLine(text)
            }
           Button {
                id:sendBut
                color: uMatriks.theme.palette.normal.background
                iconName:"send"
                enabled: true
                height:parent.height
                width:height
                onClicked: if(textEntry.text) sendLine(textEntry.text);
            }
        }
    }
}
