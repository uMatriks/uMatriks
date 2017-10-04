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

    property Connection connection: null
    property bool initialised: false
    property bool loggedOut: false
    property int activeRoomIndex: -1
    signal leaveRoom(var room)

    Settings   {
        id: settings

        property string user: ""
        property string token: ""
        property string homeserver: ""
        property bool theme: false
        property bool devScan: false

        property alias winWidth: roomList.width
        property alias winHeight: roomList.height
    }

    MatrixConn {
        id: matrixconn
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
        settings.homeserver = "";
    }

    function login(user, pass, server, connectWithToken) {

        if(!server) server = "https://matrix.org"
        connection = matrixconn.createConnection(server)
        connection.loginError.connect(login.loginError)

        var matrixconnect
        if(!connectWithToken)
            matrixconnect = connection.connectToServer
        else
            matrixconnect = connection.connectWithToken

        // TODO: apparently reconnect is done with password but only a token is available so it won't reconnect
        connection.connected.connect(function() {
            settings.user = connection.userId()
            settings.token = connection.token()
            settings.homeserver = connection.homeserver()

            connection.syncError.connect(reconnect)
            connection.resolveError.connect(reconnect)
            connection.syncDone.connect(resync)
            connection.reconnected.connect(resync)

            connection.sync()
        })

        matrixconnect(user, pass)
        if(loggedOut)
        {
            pageStack.pop()
            pageStack.push(roomList)
        }
        leaveRoom.connect(connection.leaveRoom)
    }

    Login {
        id: login
        anchors.fill: parent
        Component.onCompleted: {
            var user = settings.user
            var token = settings.token
            var server = settings.homeserver
            if(user && token) {
                login.login(true)
                uMatriks.login(user, token, server, true)
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
