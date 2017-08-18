import QtQuick 2.4
import Ubuntu.Components 1.3
import Matrix 1.0


Page {
    id: loginPage
    width: parent.width
    anchors.centerIn: parent

    Connections {
        target: connection
        onLoginError: {
            if (error.indexOf("Forbidden") !== -1) {
                if(uMatriks.loggedOut)
                {
                    mainPageStack.pop(pageMain)
                    mainPageStack.push(loginPage)
                }
                passwordField.text = ""
                console.log("Wrong password")
                loadingMode(false)
                errorLabel.color = UbuntuColors.red
                errorLabel.text = i18n.tr("Wrong username or password, please try again")
                errorLabel.visible = true
                return;
            }
            console.log("unknown login error", error);
            errorLabel.visible = true
            return;
        }
    }

    header: PageHeader {
        title: i18n.tr("Login...")
//        StyleHints {
//            foregroundColor: UbuntuColors.jet
//            backgroundColor: UbuntuColors.silk
//            dividerColor: UbuntuColors.warmGrey
//        }
        leadingActionBar {
            visible: false //mainPageStack.depth != 0
//            numberOfSlots: 1
//            actions: [
//                Action {
//                    id: actionLogin
//                    iconName: "back"
//                    text: i18n.tr("Back")
//                    shortcut: "Ctrl+B"
//                    onTriggered: {
//                        onClicked:
//                        if(settings.user !== '' && settings.token !== '')
//                        {
//                            mainPageStack.pop(loginPage)
//                            pageMain.visible = true;
//                        }
//                    }
//                }
//            ]
        }

    }

    //color: "#eee"
    property variant mainPage

    function login(pretend) {
        if (userNameField.text == "" && passwordField.text == "")
            return
        loadingMode(true)
        if(!pretend) uMatriks.login(userNameField.text, passwordField.text)

    }

    function loadingMode(state){
        label.visible = !state;
        loading.visible = state;
        loading.running = state;
        userNameField.visible = !state
        passwordField.visible = !state
        userNameLabel.visible = !state
        passwordLabel.visible = !state
        loginButton.visible = !state
        errorLabel.color = UbuntuColors.green
        errorLabel.text = i18n.tr("Login...")
        errorLabel.visible = true
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

        ActivityIndicator {
            id: loading
            z:2
            visible: false
            running: false
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Label{
            id:errorLabel
            visible: false
            color: UbuntuColors.red
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n.tr("Failed to login, please try again")
        }

        Label{
            id:userNameLabel
            text: i18n.tr("User Name or Matrix ID:")
        }

        TextField {
            id: userNameField
            inputMethodHints: Qt.ImhNoAutoUppercase
            width: parent.width
            placeholderText: qsTr(settings.user)
        }

        Label{
            id:passwordLabel
            text:i18n.tr("Password:")
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
            text: i18n.tr("Login")
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
