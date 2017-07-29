import QtQuick 2.4
import Ubuntu.Components 1.3


Page {
    id: loginPage
    width: parent.width
    anchors.centerIn: parent

    header: PageHeader {
        title: i18n.tr("Login...")
        StyleHints {
            foregroundColor: UbuntuColors.jet
            backgroundColor: UbuntuColors.silk
            dividerColor: UbuntuColors.warmGrey
        }
        leadingActionBar {
            numberOfSlots: 1
            actions: [
                Action {
                    id: actionLogin
                    iconName: "back"
                    text: i18n.tr("Back")
                    shortcut: "Ctrl+B"
                    onTriggered: {
                        onClicked: mainPageStack.pop(loginPage)
                        pageMain.visible = true;
                    }
                }
            ]
        }

    }

    //color: "#eee"
    property variant mainPage

    function login(pretend) {
        label.text = qsTr("Please wait...")
        if(!pretend) uMatriks.login(userNameField.text, passwordField.text)
        userNameField.enabled = false
        passwordField.enabled = false
        userNameField.opacity = 0
        passwordField.opacity = 0
        userNameLabel.opacity = 0
        passwordLabel.opacity = 0
        loginButton.opacity = 0
    }

    Column {
        id:loginColumn
        width: parent.width / 2
        anchors.centerIn: parent
//        opacity: 0
        spacing: 18

        Item {
            width: parent.width
            height: 1
        }

        Item {
            width: 256
            height: 256
            anchors.horizontalCenter: parent.horizontalCenter
            Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                antialiasing: true
                source: "qrc:/logo.png"

//                RotationAnimation on rotation {
//                    loops: Animation.Infinite
//                    from: 0
//                    to: 360
//                    duration: 60000
//                }
            }
        }

        Label { id: phantomLabel; visible: false }

        Label {
            id: label
            font.pixelSize: phantomLabel.font.pixelSize * 5/2
            text: qsTr("[ uMatriks ]")
            color: "#888"
        }

        Label{
            id:userNameLabel
            text:"User Name or Matrix ID:"
        }

        TextField {
            id: userNameField
            width: parent.width
            placeholderText: qsTr(settings.user)
        }

        Label{
            id:passwordLabel
            text:"Password:"
        }

        TextField {
            id: passwordField
            echoMode: TextInput.Password
            width: parent.width
            placeholderText: qsTr("Password")
//            onAccepted: login()
        }

        Button{
            id: loginButton
            anchors.horizontalCenter: parent.horizontalCenter
            text:"Login"
            onClicked: login()

        }

//        NumberAnimation on opacity {
//            id: fadeIn
//            to: 1.0
//            duration: 2000
//        }

//        Component.onCompleted: fadeIn.start()
    }
}
