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


Page {
    id: loginPage
    width: parent.width
    anchors.centerIn: parent

    header: PageHeader {
        title: i18n.tr("Login...")
        leadingActionBar {
            visible: false //pageStack.depth != 0
        }

    }

    property variant roomList

    function login(pretend) {
        if (userNameField.text == "" && passwordField.text == "")
            return
        loadingMode(true)
        if(!pretend) uMatriks.login(userNameField.text, passwordField.text, homeserverField.text)

    }

    function loadingMode(state){
        label.visible = !state;
        loading.visible = state;
        loading.running = state;
        userNameField.visible = !state
        passwordField.visible = !state
        homeserverField.visible = !state
        userNameLabel.visible = !state
        passwordLabel.visible = !state
        homeserverLabel.visible = !state
        loginButton.visible = !state
        errorLabel.color = UbuntuColors.green
        errorLabel.text = i18n.tr("Login...")
        errorLabel.visible = true
    }

    function loginError(error) {
        if (error.indexOf("Forbidden") !== -1) {
            if(uMatriks.loggedOut)
            {
                mainAdaptiveLayout.removePages(pageMain)
                mainAdaptiveLayout.addPageToCurrentColumn(mainAdaptiveLayout.primaryPage,loginPage)
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
                source: settings.theme ? "./resources/logo-dark.png" : "./resources/logo.png"
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
        }

        Label {
            id: homeserverLabel
            text:i18n.tr("Home server URL:")
        }

        TextField {
            id: homeserverField
            inputMethodHints: Qt.ImhNoAutoUppercase
            width: parent.width
            placeholderText: "https://matrix.org"
        }

        Button{
            id: loginButton
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n.tr("Login")
            onClicked: login()

        }
    }
}
