import QtQuick 2.4
import Ubuntu.Components 1.3
import Qt.labs.settings 1.0
import 'jschat.js' as JsChat



//Page{
//    id:roomPage
//    header: PageHeader {
//        title: i18n.tr("room") //Here we need to show the roomLabel
//        StyleHints {
//            foregroundColor: UbuntuColors.jet
//            backgroundColor: UbuntuColors.silk
//            dividerColor: UbuntuColors.warmGrey
//        }
//        leadingActionBar {
//            numberOfSlots: 1
//            actions: [
//                Action {
//                    id: actionSettings
//                    iconName: "back"
//                    text: i18n.tr("Back")
//                    shortcut: "Ctrl+B"
//                    onTriggered: {
//                        onClicked: mainPageStack.pop(roomViewItem)
//                        pageMain.visible = true;
//                    }
//                }
//            ]
//        }

//    }


Flickable {
    id: room

    property var currentRoom
    property var completion

    signal changeRoom(int dir)

    function setRoom(room) {
        currentRoom = room
        chat.setRoom(room)
    }

    function setConnection(conn) {
        chat.setConnection(conn)
    }

    function displayStatus(stat) {
        chat.status = stat
    }

    function sendLine(line) {
        chat.sendLine(line)
        textEntry.text = ''
    }

    function onKeyPressed(event, isBackTab) {
        if ((event.key === Qt.Key_Tab) || (event.key === Qt.Key_Backtab)) {
            if (completion === null) completion = new JsChat.NameCompletion(currentRoom.memberNames(), textEntry.text);
            event.accepted = true;
            textEntry.text = completion.complete(event.key === Qt.Key_Tab);

        } else if ((event.key !== Qt.Key_Shift) && (event.key !== Qt.Key_Alt) && (event.key !== Qt.Key_Control)) {
            // reset
            completion = null;
        }

        if (isBackTab) return;

        if ((event.modifiers & Qt.ControlModifier) === Qt.ControlModifier) {
            if (event.key === Qt.Key_PageUp) {
                event.accepted = true;
                changeRoom(-1);
            }
            else if (event.key === Qt.Key_PageDown) {
                event.accepted = true;
                changeRoom(1);
            }
        } else if (event.key == Qt.Key_PageUp) {
            chat.scrollPage(-1);

        } else if (event.key == Qt.Key_PageDown) {
            chat.scrollPage(+1);

        }

    }







    ChatRoom {
        id: chat
        anchors.bottom: textEntry.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
    }


    TextField {
        id: textEntry
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        focus: true

        placeholderText: qsTr("Say something...")
        onAccepted: sendLine(text)

        Keys.onBacktabPressed: onKeyPressed(event, true)
        Keys.onPressed: onKeyPressed(event, false)
    }
}

//}




