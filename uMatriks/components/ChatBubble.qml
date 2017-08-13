import QtQuick 2.4
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0
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
        radius: height/2
//        anchors.margins: 20
        anchors.margins: units.gu(0.5)
        clip: true
        border.color: "black"


        Image {
            id: avatarImg
            anchors.fill: parent
            visible: false
        }

        OpacityMask {
            anchors.fill: avatarImg
            source: avatarImg
            maskSource: Rectangle {
                width: avatarImg.width
                height: avatarImg.height
                radius: height/2
                visible: false
            }
        }
    }

    Rectangle {
        id: rect
        anchors.top: chatBubble.top
        anchors.margins: {
//            right: 20
//            left: 20
            right: units.gu(1)
            left: units.gu(1)
        }
        border.color: "grey"
        border.width: 1
        radius: 8

        Text {
            id: contentlabel
            text: content
            wrapMode: Text.Wrap
            font.pointSize: units.gu(1.5)
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: units.gu(1)

//            color: "white"
//            linkColor: "black"
            color: "black"
            linkColor: "blue"
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
                text: time.toLocaleDateString("dd:mm:yy") + ' ' + time.toLocaleTimeString("hh:mm:ss")
                font.pointSize: units.gu(0.9)
            }
            Text {
                id: dashlabel
                text: " - "
                font.pointSize: units.gu(0.9)
            }
            Text {
                id: authorlabel
                text: eventType == "message" ? author : "***"
                font.pointSize: units.gu(0.9)
            }
        }

        function checkForLink()
        {
            if (content.search("https://") !== -1 || content.search("http://") !== -1)
            {
                if((content.search(".png") !== -1 || content.search(".jpg") !== -1 || content.search(".gif") !== -1))
                {
                    var start = content.search("https://") !== -1 ? content.search("https://") : content.search("http://");
                    var end;
                    var url;
                    if(content.search(".gif") !== -1)
                    {
                        end = content.search(".gif");
                        url = content.slice(start, end + 4);
                        contentAnimatedImage.source = url;
                        contentAnimatedImage.visible = true;
                        contentAnimatedImage.anchors.top = contentlabel.bottom;
                        rect.height += contentAnimatedImage.height;
                    }
                    else
                    {
                        end = content.search(".png") !== -1 ? content.search(".png") : content.search(".jpg");
                        url = content.slice(start, end + 4);
                        contentImage.source = url;
                        contentImage.visible = true;
                        contentImage.anchors.top = contentlabel.bottom;
                        rect.height += contentImage.height;
                    }
                }

                var words = content.split(" ");
                var i;
                for (i = 0; i < words.length; i++) {
                    if((words[i].search("https://") !== -1 || words[i].search("http://") !== -1) && words[i].search('href=') === -1)
                    {
                        var newContent = content.replace(words[i], '<a href="' + words[i] + '">' + words[i] + '</a>');
                        console.log(newContent);
                        contentlabel.text = newContent;
                    }
                }

            }
        }


        Component.onCompleted: {
            if (eventType == "message"){
                if (msgType === "m.image"){
                    contentImage.width = chatBubble.width - avatarIcon.width - 40 - 30
                    width = Math.max(contentImage.width, innerRect.width) + 30
                    height = Math.max(contentImage.height + innerRect.height + 40, avatarIcon.height)
                }   else {
                    contentlabel.width = Math.min(contentlabel.contentWidth, chatBubble.width - avatarIcon.width - 40 - 30)
                    contentlabel.height = contentlabel.contentHeight
                    width = Math.max(contentlabel.width, innerRect.width) + 30
                    height = Math.max(contentlabel.height + innerRect.height + 40, avatarIcon.height)
                }
            }
            checkForLink();
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
//                rect.color = "#2ecc71"
                rect.color = "#9E7D96"
                contentlabel.color = "white"
                timelabel.color = UbuntuColors.lightGrey
                authorlabel.color = UbuntuColors.lightGrey
                dashlabel.color = UbuntuColors.lightGrey

            } else {
                avatarIcon.anchors.left = chatBubble.left
                rect.anchors.left = avatarIcon.right
//                rect.color = "#bdc3c7"
            }

            if (msgType === "m.image") {
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

