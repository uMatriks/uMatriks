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
    
    property Connection connection: null
    property bool initialised: false
    property int syncIx: 0
    property bool loggedOut: false
    property int activeRoomIndex: -1
    property bool roomListComplete: false

    signal componentsComplete();
    signal leaveRoom(var room)

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

    Settings   {
        id: settings

        property string user: ""
        property string accessToken: ""
        property string homeserver: ""
        property bool theme: false
    }

    function resync() {
        if(!initialised) {
            roomList.init(connection)
            mainAdaptiveLayout.addPageToCurrentColumn(mainAdaptiveLayout.primaryPage,roomList)
            initialised = true
        }
        syncIx += 1

        connection.sync(30000)
        // every now and then but not on the first sync
        if ((syncIx % 10) == 2) { 
            console.log("Saving state: " + syncIx)
            connection.saveState(connection.stateSaveFile)
        }
    }

    function reconnect() {
        connection.connectWithToken(connection.localUserId,
                                    connection.accessToken,
                                    connection.deviceId)
    }

    function logout() {
        connection.logout();
        loggedOut = true;
        settings.user = "";
        settings.accessToken = "";
        settings.homeserver = "";
    }

    function login(user, pass, server, hasToken) {

        if(!server) server = "https://matrix.org"
        connection = matrixHelper.createConnection(server)
        connection.loginError.connect(login.loginError)

        var matrixConn
        if(!hasToken)
            matrixConn = connection.connectToServer
        else
            matrixConn = connection.connectWithToken

        // TODO: apparently reconnect is done with password but only a accessToken is available so it won't reconnect
        connection.connected.connect(function() {
            settings.user = connection.localUserId
            settings.accessToken = connection.accessToken
            settings.homeserver = connection.homeserver

            connection.syncError.connect(reconnect)
            connection.resolveError.connect(reconnect)
            connection.syncDone.connect(resync)
            connection.reconnected.connect(resync)

            var startSyncFn = function() {
                connection.loadState(connection.stateSaveFile)
                connection.sync()
            }
            if (roomListComplete) startSyncFn()
            else componentsComplete.connect(startSyncFn)
        })


        // TODO save deviceId to settings
        // console.log("dev: " + connection.deviceId)
        matrixConn(user, pass, connection.deviceId)
        if(loggedOut)
        {
            mainAdaptiveLayout.addPageToCurrentColumn(mainAdaptiveLayout.primaryPage, roomList)
        }
        leaveRoom.connect(connection.leaveRoom)
    }

    AdaptivePageLayout {
       id:mainAdaptiveLayout
       anchors.fill: parent
       primaryPage: login
    }
    Login {
        id: login
        objectName: "login"
        anchors.fill: parent
        Component.onCompleted: {
            var user = settings.user
            var accessToken = settings.accessToken
            var server = settings.homeserver

            if(user && accessToken) {
                login.login(true)
                uMatriks.login(user, accessToken, server, true)
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
