import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.3
import Qt.labs.settings 1.0
import Matrix 1.0
import Ubuntu.Components.Popups 1.3

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

    theme: ThemeSettings {
        name: settings.theme ? "Ubuntu.Components.Themes.SuruDark" : "Ubuntu.Components.Themes.Ambiance"
    }

    width: units.gu(50)
    height: units.gu(80)


    property bool initialised: false
    property bool loggedOut: false
    property int activeRoomIndex: -1
    signal joinRoom(string name)
    signal joinedRoom(string room)
    signal leaveRoom(var room)

    Settings   {
        id: settings

        property string user: ""
        property string token: ""
        property bool theme: false

        property alias winWidth: pageMain.width
        property alias winHeight: pageMain.height
    }

    function checkForLink(string)
    {
        if (string.search("https://") !== -1 || string.search("http://") !== -1)
        {
            var words = string.split(" ");
            var i;
            for (i = 0; i < words.length; i++) {
                if((words[i].search("https://") !== -1 || words[i].search("http://") !== -1) && words[i].search('href=') === -1)
                {
                    var newContent = string.replace(words[i], '<a href="' + words[i] + '">' + words[i] + '</a>');
                    console.log(newContent);
                    string = newContent;
                }
            }
            return string;

        }
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
            if(loggedOut)
            {
                mainPageStack.pop()
                mainPageStack.push(pageMain)
            }
        } else {
            connection.resolved.connect(function() {
                connect(user, pass)
                if(loggedOut)
                {
                    mainPageStack.pop()
                    mainPageStack.push(pageMain)
                }
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
//                            StyleHints {
//                                foregroundColor: UbuntuColors.jet
//                                backgroundColor: UbuntuColors.silk
//                                dividerColor: UbuntuColors.warmGrey
//                }
                leadingActionBar {
                    numberOfSlots: 1
                    actions: [
                       Action {
                            id: actionLogin
                            iconName: "system-log-out"
                            shortcut: "Ctrl+M"
                            text: i18n.tr("Log out")
                            onTriggered: {
                                logout();
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
                trailingActionBar {
                    numberOfSlots: 1
                    actions: [
                    Action {
                            id: actionTheme
                            iconName: settings.theme ? "torch-off" : "torch-on"
                            onTriggered: {
                                settings.theme = !settings.theme
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

                color: uMatriks.theme.palette.normal.background

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

//                StyleHints {
//                    foregroundColor: UbuntuColors.jet
//                    backgroundColor: UbuntuColors.silk
//                    dividerColor: UbuntuColors.warmGrey
//                }
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
                                activeRoomIndex = -1
                                pageMain.visible = true
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

        Page {
            id: memberListItem
            anchors.fill: parent
            visible: false

            property var members

            header: PageHeader {
                title: i18n.tr("Members")

//                StyleHints {
//                    foregroundColor: UbuntuColors.jet
//                    backgroundColor: UbuntuColors.silk
//                    dividerColor: UbuntuColors.warmGrey
//                }
                leadingActionBar {
                    numberOfSlots: 1
                    actions: [
                        Action {
                            //id: actionSettings
                            iconName: "back"
                            text: i18n.tr("Back")
                            shortcut: "Ctrl+B"
                            onTriggered: {
                                onClicked: mainPageStack.pop(memberListItem)
                                activeRoomIndex = -1
                                pageMain.visible = true
                            }
                        }
                    ]
                }

            }


            Column {
                id: memberListColumn
                anchors.fill: parent

                ListView {
                    id: membersListView
                    model: memberListItem.members
                    width: parent.width
                    height: parent.height

                    delegate: ListItem {
                        height: memberListLayout.height + (divider.visible ? divider.height : 0)
                        ListItemLayout {
                            id: memberListLayout
                            title.text: modelData
                            title.color: uMatriks.theme.palette.normal.backgroundText
                        }

                        trailingActions: ListItemActions {
                            actions: [
                                Action {
                                    iconName: "add" //change icon
                                    onTriggered: {
                                        // console.log("Add Room with: " + modelData);
                                        var userId = (modelData.search(":matrix.org") === -1) ? ("@" + modelData + ":matrix.org") : modelData;
                                        // joinRoom(userId);
                                        var popup = PopupUtils.open(warning, memberListItem);
                                        popup.description = i18n.tr("Failed to add direct chat with ")
                                        popup.description += userId
                                        popup.description += i18n.tr(" because this is not implented yet. This was just a test button.")
                                    }
                                }
                            ]
                        }

                        onClicked: {
                            var userId = (modelData.search(":matrix.org") === -1) ? ("@" + modelData + ":matrix.org") : modelData
                            console.log(userId)
                        }
                    }
                }
            }
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
