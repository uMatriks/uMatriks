import QtQuick 2.0
import Ubuntu.Web 0.2
import com.canonical.Oxide 1.19 as Oxide
import Matrix 1.0

import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.3

Page {
    id: callPage

    property string myUA: "Mozilla/5.0 (Linux; Android 5.0; Nexus 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.102 Mobile Safari/537.36"
    property string usContext: "messaging://"

    property var currentRoom;
    property var currentConnection;
    property var callId;
    property var roomId;
    property var eventQueue: [];
    property var waitEventQueue: [];
    property var processingQueue;
    property var turnServer;
    property var inCall;
    property var callingOutgoing;
    property var videoCall;
    property var gotAnswer;

    IncommingCallPage {
      id: incommingCallPage
    }

    MatrixAudio {
      id: matrixAudio
    }

    function init(room, conn, server){
      callingOutgoing = false;
      inCall = false;
      videoCall = false;
      gotAnswer = false;
      currentRoom = room;
      currentConnection = conn;
      turnServer = server;
      callId = "c" + new Date().getTime();
      roomId = room.id;
      header.title = "Call with " + room.displayName;
      eventQueue.push({function: "setTurnServers", data: turnServer});
      eventQueue.push({function: "init", data: {roomId: roomId, callId: callId}});
      console.log("Call Init: ", currentRoom.id, callId);
      avatarImg.source = getAvatarUrl();
    }

    function placeVideoCall() {
      inCall = true;
      callingOutgoing = true;
      videoCall = true;
      matrixAudio.ringBack();
      eventQueue.push({function: "placeVideoCall", data: {}});
      eventQueueNext();
      callPage.visible = true;
    }

    function placeVoiceCall() {
      inCall = true;
      callingOutgoing = true;
      videoCall = false;
      matrixAudio.ringBack();
      eventQueue.push({function: "placeVoiceCall", data: {}});
      eventQueueNext();
      callPage.visible = true;
    }

    function hangup() {
      matrixAudio.stop();
      webview.rootFrame.sendMessage("messaging://", "hangup", {});
      pageStack.pop(callPage)
      roomList.inCall = false;
      inCall = false;
      callingOutgoing = false;
    }

    function answer() {
      matrixAudio.stop();
      webview.rootFrame.sendMessage("messaging://", "answer", {});
      roomList.inCall = true;
      inCall = true;
      callPage.visible = true;
      callingOutgoing = false;
    }

    function toggleSpeaker() {
      console.log("toggleSpeaker");
    }

    function switchCamera() {
      console.log("switchCamera");
    }

    function toggleMic() {
      console.log("toogleMic");
    }

    function toggleCam() {
      console.log("toggleCam");
    }

    function onAction(action) {
      switch(action){
      case "toggleSpeaker":
        toggleSpeaker();
        break;
      case "hangup":
        hangup();
        break;
      case "switchCamera":
        switchCamera();
        break;
      case "toggleMic":
        toggleMic();
        break;
      case "toggleCam":
        toggleCam();
        break;
      }
    }

    function getAvatarUrl() {
      // Let's not even try pixmap...
      var rawAvatarUrl = currentRoom.avatarUrl().toString();
      var host = currentConnection.homeserver().toString();
      if (!host || host == "")
        host = "https://matrix.org"
      rawAvatarUrl = rawAvatarUrl.replace("mxc://", "/");
      var avatarUrl = host + "/_matrix/media/v1/download" + rawAvatarUrl
      console.log(avatarUrl);
      return avatarUrl;
    }

    function isVideo(sdpValue) {
      videoCall = sdpValue.indexOf("m=video") >= 0;
    }

    function triggerWaitEventQueue() {
      if (waitEventQueue.length === 0) {
        console.log("call: No waitEventQueue")
        return;
      }

      console.log("call: processing wait events");
      eventQueue = eventQueue.concat(waitEventQueue);
      waitEventQueue = [];
      eventQueueNext();
    }

    function eventQueueNext(currentProccess) {
      console.log("call: eventQueueNext")
      if (eventQueue.length === 0) {
        console.log("call: Done processingQueue")
        processingQueue = false;
        return;
      }

      if (!currentProccess)
        if (processingQueue)
          return;

      processingQueue = true;

      var event = eventQueue.shift();
      console.log("call: processing: "+ event.function)
      var req = webview.rootFrame.sendMessage("messaging://", event.function,
                                              event.data);
      req.onreply = function (msg) {
        console.log("call: Got reply: " + msg.str);
        eventQueueNext(true);
      }
      req.onerror = function (code, explanation) {
         eventQueueNext(true);
         console.log("call: Error " + code + ": " + explanation)
      }
    }

    function newEvent(type, event) {
      var eventJ = event;
      eventJ["room_id"] = roomId;
      switch(type) {
      case "invite":
        if (!inCall){
          console.log("Incomming call!");
          isVideo(eventJ.offer.sdp);
          incommingCallPage.incommingCall(callPage, currentRoom);
          pageStack.push(incommingCallPage);
          eventQueue.push({function: "initWithInvite", data: eventJ});
          inCall = true;
        }else{
          console.log("We are in a call!, Ignore any incomming calls");
        }
        break;
      case "candidates":
        console.log("call: got candidates");
        if (!gotAnswer && callingOutgoing){
          console.log("call: Adding to wait queue")
          waitEventQueue.push({function: "gotRemoteCandidates", data: eventJ});
        }
        else
          eventQueue.push({function: "gotRemoteCandidates", data: eventJ});
        break;
      case "answer":
        console.log("call: got answer")
        console.log(eventJ.answer.sdp);
        eventQueue.push({function: "receivedAnswer", data: eventJ});
        matrixAudio.stop();
        triggerWaitEventQueue();
        gotAnswer = true;
        callingOutgoing = false;
        break;
      case "hangup":
        console.log("call: got hangup")
        eventQueue.push({function: "onHangupReceived", data: eventJ});
        pageStack.pop(callPage);
        roomList.inCall = false;
        matrixAudio.stop();
        if (callingOutgoing)
          matrixAudio.busy();
        else
          matrixAudio.callEnd();
        callingOutgoing = false;
        break;
      }
      eventQueueNext();
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
        title: i18n.tr("Call")
    }

    Image {
      id: avatarImg
      anchors {
          top: header.bottom
          left: parent.left
          right: parent.right
          bottom: actionsRow.top
      }
      visible: !videoCall
      fillMode: Image.PreserveAspectCrop
    }

    WebView {
        id: webview
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: actionsRow.top
        }
        visible: videoCall
        context: webcontext
        url: Qt.resolvedUrl("call.html")
        preferences.localStorageEnabled: true
        preferences.allowFileAccessFromFileUrls: true
        preferences.allowUniversalAccessFromFileUrls: true
        preferences.appCacheEnabled: true
        preferences.javascriptCanAccessClipboard: true
        onMediaAccessPermissionRequested: { request.allow() }
        messageHandlers: [
         Oxide.ScriptMessageHandler {
            msgId: "event"
            contexts: ["messaging://"]
            callback: function(msg, frame) {
                var content = JSON.parse(msg.args.content)
                switch(msg.args.event.replace(/[^0-9a-z.]/gi, '')){
                case "m.call.invite":
                  console.log("call: invite", content["call_id"],
                                        content["lifetime"],
                                        content["offer"]["sdp"]);
                  currentRoom.inviteCall(content["call_id"],
                                         content["lifetime"],
                                         content["offer"]["sdp"]);
                  break;
                case "m.call.candidates":
                  console.log("call: candidates", content["call_id"],
                                            content["candidates"]);
                  currentRoom.callCandidates(content["call_id"],
                                             content["candidates"]);
                  break;
                case "m.call.answer":
                  currentRoom.answerCall(content["call_id"],
                                         content["answer"]["sdp"])
                  matrixAudio.stop();
                  gotAnswer = true;
                  callingOutgoing = false;
                  break;
                case "m.call.hangup":
                  console.log("call: hangup", content["call_id"]);
                  currentRoom.hangupCall(content["call_id"]);
                  matrixAudio.stop();
                  if (callingOutgoing)
                    matrixAudio.busy();
                  else
                    matrixAudio.callEnd();
                  callingOutgoing = false;
                  break;
                }
            }
        }
    ]
    }

    WebContext {
        id: webcontext
        userScripts: [
            Oxide.UserScript {
                context: "messaging://"
                url: Qt.resolvedUrl("call.js")
            }
        ]
        Component.onCompleted: {
        }
    }
    ListModel {
        id: modelButtons
        ListElement { icon: "audio-speakers-symbolic"; actionType: "toggleSpeaker" }
        ListElement { icon: "camera-flip"; actionType: "switchCamera" }
        ListElement { icon: "missed-call"; actionType: "hangup" }
        ListElement { icon: "audio-input-microphone-muted-symbolic"; actionType: "toggleMic" }
        ListElement { icon: "camera-web-symbolic"; actionType: "toggleCam" }
    }

    Row {
      id: actionsRow
      anchors {
          bottom: parent.bottom
          left: parent.left
          right: parent.right
      }

      Repeater {
          id: repeaterButton
          model: modelButtons
          delegate: Button {
              width: actionsRow.width / repeaterButton.model.count
              iconName: icon
              color: "transparent"
              onClicked: onAction(actionType)
          }
      }
    }
}
