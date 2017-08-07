import QtQuick 2.0
import Ubuntu.Components 1.3
import Matrix 1.0
//import '../jschat.js' as JsChat

Item {
    id: chatBubble

    height: Math.max(avatarIcon.height, rect.height)

    property var room: null

    Rectangle {
        id: avatarIcon
        height: units.gu(6)
        anchors.top: chatBubble.top
        width: height
        radius: 10
        anchors.margins: 20
        clip: true

        Image {
            id: avatarImg
            anchors.fill: parent
        }
    }

    Rectangle {
        id: rect
        anchors.top: chatBubble.top
        anchors.margins: {
            right: 20
            left: 20
        }
        border.color: "grey"
        border.width: 1
        radius: 10

            Text {
                id: contentlabel
                text: content
                wrapMode: Text.Wrap
                font.pointSize: units.gu(1.5)
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.margins: 15
                color: "white"
                linkColor: "black"
                textFormat: Text.RichText
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Image {
                id: contentImage
                visible: false
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.margins: 15
                fillMode: Image.PreserveAspectFit
                height: units.gu(20)
                width:  height
                anchors.horizontalCenter: parent.horizontalCenter
            }

            AnimatedImage {
                id: contentAnimatedImage
                visible: false
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.margins: 15
                fillMode: Image.PreserveAspectFit
                height: units.gu(20)
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                id: innerRect
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.margins: 5

                Text {
                    id: timelabel
                    text: time.toLocaleTimeString("hh:mm")
                    font.pointSize: units.gu(0.9)
                }
                Text {
                    text: " - "
                    font.pointSize: units.gu(0.9)
                }
                Text {
                    id: authorlabel
                    text: eventType == "message" ? author : "***"
                    font.pointSize: units.gu(0.9)
                }
            }

            function checkForImgLink()
            {

                var cont;

                if (content.search("https://") != -1)
                    cont = content.replace("https://", "http://");
                else
                    cont = content;

                if(cont.search("http://") != -1 && (cont.search(".png") != -1 || cont.search(".jpg") != -1 || cont.search(".gif") != -1))
                {
                    var start = cont.search("http://");
                    var end;
                    var url;
                    if(content.search(".gif") != -1)
                    {
                        end = cont.search(".gif");
                        url = cont.slice(start, end + 4);
                        contentAnimatedImage.source = url;
                        contentAnimatedImage.visible = true;
                        contentAnimatedImage.anchors.top = contentlabel.bottom;
                        rect.height += contentAnimatedImage.height;
                    }
                    else
                    {
                        end = cont.search(".png") != -1 ? cont.search(".png") : cont.search(".jpg");
                        url = cont.slice(start, end + 4);
                        contentImage.source = url;
                        contentImage.visible = true;
                        contentImage.anchors.top = contentlabel.bottom;
                        rect.height += contentImage.height;
                    }
                }
            }


            Component.onCompleted: {
                if (eventType == "message"){
                    if (msgType === "image"){
                        contentImage.width = chatBubble.width - avatarIcon.width - 40 - 30
                        width = Math.max(contentImage.width, innerRect.width) + 30
                        height = Math.max(contentImage.height + innerRect.height + 40, avatarIcon.height)
                    }   else {
                        contentlabel.width = Math.min(contentlabel.contentWidth, chatBubble.width - avatarIcon.width - 40 - 30)
                        contentlabel.height = contentlabel.contentHeight
                        width = Math.max(contentlabel.width, innerRect.width) + 30
                        height = Math.max(contentlabel.height + innerRect.height + 40, avatarIcon.height)
                        checkForImgLink();
                    }
                }
            }
    }

    Component.onCompleted: {
        if (eventType == "message"){

            if (avatar) {
                avatarImg.source = avatar;
            }

            if (userId === connection.userId()) {
                avatarIcon.anchors.right = chatBubble.right
                rect.anchors.right = avatarIcon.left
                rect.color = "#2ecc71"
            } else {
                avatarIcon.anchors.left = chatBubble.left
                rect.anchors.left = avatarIcon.right
                rect.color = "#bdc3c7"
            }

            if (msgType === "image") {
                contentImage.sourceSize = "1000x1000"
                contentImage.source = content;
                contentImage.visible = true;
                contentlabel.visible = false;
            }
        } else {
            innerRect.visible = false
            avatarIcon.visible = false
            rect.color = "white"
            rect.border.width = 0
            contentlabel.color = UbuntuColors.graphite;
            contentlabel.font.pointSize = units.gu(0.9)
            contentlabel.width = contentlabel.contentWidth
            contentlabel.height = contentlabel.contentHeight
            rect.height = contentlabel.contentHeight
            rect.width = contentlabel.width;
            rect.anchors.horizontalCenter = horizontalCenter
            height = rect.height + 20
        }
    }
}
