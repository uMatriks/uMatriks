import QtQuick 2.4
import Ubuntu.Components 1.3
import Qt.labs.settings 1.0
import Matrix 1.0

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    id: uMatriks
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "umatriks.larreamikel"

    // automatically anchor items to keyboard that are anchored to the bottom
    anchorToKeyboard: true

    width: units.gu(50)
    height: units.gu(90)


    property bool initialised: false
    signal joinRoom(string name)
    signal joinedRoom(string room)
    signal leaveRoom(var room)

    Settings   {
        id: settings

        property string user: ""
        property string token: ""

        property alias winWidth: pageMain.width
        property alias winHeight: pageMain.height
    }


    function resync() {
        if(!initialised) {
            login.visible = false
            pageMain.visible = true
            roomListItem.init()
            initialised = true
        }
        connection.sync(30000)
    }

    function reconnect() {
        connection.connectWithToken(connection.userId(), connection.token())
    }


    function login(user, pass, connect) {
        if(!connect) connect = connection.connectToServer

        // TODO: apparently reconnect is done with password but only a token is available so it won't reconnect
        connection.connected.connect(function() {
            settings.user = connection.userId()
            settings.token = connection.token()
            roomView.displayStatus("connected")

            connection.syncError.connect(reconnect)
            connection.syncError.connect(function() { roomView.displayStatus("sync error")})
            connection.resolveError.connect(reconnect)
            connection.resolveError.connect(function() { roomView.displayStatus("resolve error")})
            connection.syncDone.connect(resync)
            connection.syncDone.connect(function() { roomView.displayStatus("synced") })
            connection.reconnected.connect(resync)

            connection.sync()
        })

        var userParts = user.split(':')
        if(userParts.length === 1 || userParts[1] === "matrix.org") {
            connect(user, pass)
        } else {
            connection.resolved.connect(function() {
                connect(user, pass)
            })
            connection.resolveError.connect(function() {
                console.log("Couldn't resolve server!")
            })
            connection.resolveServer(userParts[1])
        }
        joinRoom.connect(connection.joinRoom)
        joinedRoom.connect(connection.joinedRoom)
        leaveRoom.connect(connection.leaveRoom)
    }




    PageStack {
        id: mainPageStack
        anchors.fill: parent
        width: parent.width


        Page{
            id:pageMain
            visible: false
            anchors{
                fill: parent
            }

            header: PageHeader{
                id:pageHeader

                title: i18n.tr("[ uMatriks ]")
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
                            iconName: "system-log-out"
                            shortcut: "Ctrl+M"
                            text: i18n.tr("Log out")
                            onTriggered: {
                                pageMain.visible = false;
                                mainPageStack.push(Qt.resolvedUrl("Login.qml"))
                            }
                       },
                        Action {
                             id: actionInfo
                             iconName: "info"
                             text: i18n.tr("About")
                             onTriggered: {
                                 pageMain.visible = false;
                                 mainPageStack.push(Qt.resolvedUrl("About.qml"))
                             }
                        }
                    ]
                }
            }

            RoomList {
                id: roomListItem
                width: parent.width
                height: parent.height - pageHeader.height
                anchors.top: pageHeader.bottom

                Component.onCompleted: {
                    setConnection(connection)
                    enterRoom.connect(roomView.setRoom)
                    joinRoom.connect(connection.joinRoom)
                }
            }

        }


        Page {
            id: roomViewItem
            anchors.fill: parent
            visible: false

            header: PageHeader {
                title: i18n.tr("Room")

                StyleHints {
                    foregroundColor: UbuntuColors.jet
                    backgroundColor: UbuntuColors.silk
                    dividerColor: UbuntuColors.warmGrey
                }
                leadingActionBar {
                    numberOfSlots: 1
                    actions: [
                        Action {
                            id: actionSettings
                            iconName: "back"
                            text: i18n.tr("Back")
                            shortcut: "Ctrl+B"
                            onTriggered: {
                                onClicked: mainPageStack.pop(roomViewItem)
                                pageMain.visible = true;
                            }
                        }
                    ]
                }

            }


                RoomView {
                    id: roomView
                    width: parent.width
                    height: parent.height
                    Component.onCompleted: {
                        setConnection(connection)
                        roomView.changeRoom.connect(roomListItem.changeRoom)
                    }
                }
//            }
        }

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
            }
        }
    }

}
