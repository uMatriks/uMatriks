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
import Ubuntu.Components.Popups 1.3 as Popup
import Ubuntu.Components.Themes 1.3
import Qt.labs.settings 1.0
import Matrix 1.0
import Ubuntu.OnlineAccounts.Client 0.1
import Ubuntu.PushNotifications 0.1

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

    //Push Client elements
    property alias pushClient: push_client_loader.item
    property bool readyForPush: false
    signal pushLoaded()
    signal pushRegister(string token, string version)
    signal pushUnregister(string token)

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

        //Register on UBports push server and obtain token
	      if (!push_client_loader.active) {
            push_client_loader.active = true;
        } else if (push_client_loader.status === Loader.Ready) {
            pushClient.registerForPush();
        }
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
        Popup.Dialog {
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
    Loader {
          id: push_client_loader
          active: false
          asynchronous: false
          sourceComponent: PushClient {
              id: push_client
              //appId: MainView.applicationName
              appId: "umatriks.larreamikel_uMatriks" //provisional solution hardcoded as MainView.applicationName does not return a QString

              property bool registered: false
              property bool loggedIn: readyForPush

              function registerForPush() {
                  if (registered) {
                    console.log("Already registered for Push"); //To see if
                    return;
                  }

      //TODO: Check from saved settings if push is enabled and we should register for it
                  //if (!uMatriks.pushNotifications) {
                  //    console.warn("push - ignoring, notifications disabled");
                  //    return;
                  //}

                  if (token.length === 0) {
                      console.warn("push - can't register, empty token.");
                      return;
                  }
                  if (!readyForPush) {
                      console.warn("push - can't register, not logged-in yet.");
                      return;
                  }

                  console.log("push - registering with Matrix server");
                  registered = true;
                  pushRegister(token, Version.version);
              }

              function unregisterFromPush() {
                  console.log("push - unregistering from Matrix server");
                  pushUnregister(token);
                  registered = false;
              }

              onTokenChanged: {
                  console.log("push - token changed: " + (token.length > 0 ? "present" : "empty!"));
                  if (token.length > 0) {
                      registered = false;
                      registerForPush();
                  }
              }

              // onConnectedChanged: {
              //     if (token.length > 0) {
              //         registerForPush();
              //     }
              // }

              onError: {
                  if (status == "bad auth") {
                      console.warn("push - 'bad auth' error: " + status);
                      if (uMatriks.promptForPush) {
                          push_dialog_loader.active = true;
                      }
                  } else {
                      console.warn("push - unhandled error: " + status);
                  }
              }
          }

          onStatusChanged: {
              if (status === Loader.Loading) {
                  console.log("push - push client loading");
              } else if (status === Loader.Ready) {
                  console.log("push - push client loaded");
              }
          }

          onLoaded: {
              pushLoaded();
          }
      }

      Loader {
          id: push_dialog_loader
          active: false
          asynchronous: false
          sourceComponent: Component {
              id: push_dialog_component
              Popup.Dialog {
                  id: push_dialog
                  title: i18n.tr("Notifications")
                  text: i18n.tr("If you want Matrix notifications when you're not using the app, sign in to your Ubuntu One account.")

                  function close() {
                      PopupUtils.close(push_dialog);
                  }

                  Button {
                      text: i18n.tr("Sign in to Ubuntu One")
                      color: UbuntuColors.orange
                      onClicked: {
                          setup.exec();
                          close();
                      }
                  }
                  Button {
                      text: i18n.tr("Remind me later")
                      onClicked: {
        //TODO: Implement saving of settings for later: prompt again for push setup, but turn off notifications
                          close();
                      }
                  }
                  Button {
                      text: i18n.tr("Don't want notifications")
                      onClicked: {
        //TODO: Implement saving of settings for later: do not prompt again for push setup, and turn off notifications
                          pushClient.unregisterFromPush();
                          close();
                      }
                  }
              }
          }

          onLoaded: {
              openPushDialog();
          }
      }
}
