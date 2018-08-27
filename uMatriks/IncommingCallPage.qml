import QtQuick 2.4
import Ubuntu.Components 1.3

Page {
    id: incommingCallPage

    property var callPage;
    property var currentRoom;

    MatrixAudio {
      id: matrixAudio
    }

    function incommingCall(_callPage, room) {
      console.log("incommingCall");
      callPage = _callPage;
      currentRoom = room;
      matrixAudio.ring();
      userLabel.text = room.displayName;

      avatar.source = callPage.getAvatarUrl();
    }

    function hangup() {
      matrixAudio.stopRing();
      pageStack.pop(incommingCall);
      callPage.hangup();
    }

    function answer() {
      callPage.answer();
      matrixAudio.stopRing();
      callPage.visible = true;
      pageStack.pop(incommingCall);
    }

    function onAction(action) {
      switch(action){
      case "answer":
        answer();
        break;
      case "hangup":
        hangup();
        break;
      }
    }

    theme: ThemeSettings {
        name: uMatriks.theme.name
    }

    style: Rectangle {
        anchors.fill: parent
        color: uMatriks.theme.palette.normal.background
    }
    header: PageHeader {
        id: header
        title: ""
        height: 0
        visible: false
    }

    Rectangle {
      anchors {
          top: header.top
          left: parent.left
          right: parent.right
          bottom: parent.bottom
      }

      Image {
        id: avatar
        height: parent.height / 2.2
        fillMode: Image.PreserveAspectCrop
        anchors {
            left: parent.left
            right: parent.right
        }
      }

      Rectangle {
        anchors {
            top: avatar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        z: 100
        color: "#2d2d2d"

        Label {
          id: userLabel
          anchors {
              horizontalCenter: parent.horizontalCenter
              topMargin: units.gu(0.4)
          }
          font {
            pixelSize: units.gu(5.3)
            bold: true
          }
          color: "#d0d0d0"
          text: ""
        }
        Label {
          anchors {
            top: userLabel.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: units.gu(0.3)
          }
          font {
            pixelSize: units.gu(2.3)
            bold: true
          }
          color: "#979797"
          text: callPage.videoCall ? i18n.tr("Incoming video call") : i18n.tr("Incoming voice call")
        }

        ListModel {
            id: buttons
            ListElement {
                icon: "missed-call"
                bColor: "red"
                rotate: -90
                actionType: "hangup"
            }
            ListElement {
                icon: "active-call"
                bColor: "green"
                rotate: 0
                actionType: "answer"
            }
        }

        Row {
          id: incommingCallActions
          anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
          }

          Repeater {
              id: incommingCallButton
              model: buttons
              delegate: IconButton {
                  width: incommingCallActions.width / incommingCallButton.model.count
                  iconName: icon
                  iconRotate: rotate
                  iconSize: units.gu(7)
                  onClicked: onAction(actionType)
              }
          }

        }

        IconButton {
          id: messageButton
          anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: units.gu(2.5)
          }
          iconName: "message"
          iconSize: units.gu(5.5)
          color: "#979797"
        }

      }

    }
}
