import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.3
import Qt.labs.settings 1.0
import Matrix 1.0
import Ubuntu.Components.Popups 1.3


MainView {
    id: uMatriks
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "umatriks.larreamikel"

    // automatically anchor items to keyboard that are anchored to the bottom
    anchorToKeyboard: true

    theme: ThemeSettings {
        name: settings.theme ? "Ubuntu.Components.Themes.SuruDark" : "Ubuntu.Components.Themes.Ambiance"
    }

    width: units.gu(50)
    height: units.gu(75)

    RoomList {
        id: roomList
    }

    RoomView {
        id: roomView
    }

    PageStack {
        id: pageStack
    }

    MemberList {
        id: memberList
    }

    property bool initialised: false
    property bool loggedOut: false
    property int activeRoomIndex: -1
    signal leaveRoom(var room)

    Settings   {
        id: settings

        property string user: ""
        property string token: ""
        property bool theme: false
        property bool devScan: false

        property alias winWidth: roomList.width
        property alias winHeight: roomList.height
    }

    function resync() {
        if(!initialised) {
            login.visible = false
            roomList.init(connection)
            pageStack.push(roomList)
            initialised = true
        }
        connection.sync(30000)
    }

    function reconnect() {
        connection.connectWithToken(connection.userId(), connection.token())
    }

    function logout() {
        connection.logout();
        loggedOut = true;
        settings.user = "";
        settings.token = "";
    }

    function login(user, pass, connect) {
        if(!connect) connect = connection.connectToServer

        // TODO: apparently reconnect is done with password but only a token is available so it won't reconnect
        connection.connected.connect(function() {
            settings.user = connection.userId()
            settings.token = connection.token()

            connection.syncError.connect(reconnect)
            connection.resolveError.connect(reconnect)
            connection.syncDone.connect(resync)
            connection.reconnected.connect(resync)

            connection.sync()
        })

        var userParts = user.split(':')
        if(userParts.length === 1 || userParts[1] === "matrix.org") {
            connect(user, pass)
            if(loggedOut)
            {
                pageStack.pop()
                pageStack.push(roomList)
            }
        } else {
            connection.resolved.connect(function() {
                connect(user, pass)
                if(loggedOut)
                {
                    pageStack.pop()
                    pageStack.push(roomList)
                }
            })
            connection.resolveError.connect(function() {
                console.log("Couldn't resolve server!")
            })
            connection.resolveServer(userParts[1])
        }
        leaveRoom.connect(connection.leaveRoom)
    }

    Login {
        id: login
        anchors.fill: parent
        Component.onCompleted: {
            var user = settings.user
            var token = settings.token
            if(user && token) {
                login.login(true)
                uMatriks.login(user, token, connection.connectWithToken)
                login.loadingMode(true)
            }
        }
    }

    Component {
        id: warning
        Dialog {
            id: dialogInternal

            property string description

            title: "<b>%1</b>".arg(i18n.tr("Warning!"))

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
