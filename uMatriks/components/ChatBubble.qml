import QtQuick 2.4
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0
import Matrix 1.0
import '../utils.js' as Utils

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
        border.color: uMatriks.theme.palette.normal.overlayText
        color: uMatriks.theme.palette.normal.background


        Image {
            id: avatarImg
            anchors.fill: parent
            visible: false
        }

        OpacityMask {
            id: avatarMask
            anchors.fill: avatarImg
            source: avatarImg
            visible: false
            maskSource: Rectangle {
                width: avatarImg.width
                height: avatarImg.height
                radius: height/2
                visible: false
            }
        }

        Text {
            id: avatarText
            visible: false
            anchors{
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }
            font.bold: true
            font.pointSize: units.gu(2)
            text: authorlabel.text[0]+authorlabel.text[1]
            color: uMatriks.theme.palette.normal.backgroundText

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
        border.color: uMatriks.theme.palette.normal.raisedSecondaryText
        border.width: 1
        radius: 8
        color: uMatriks.theme.palette.normal.background

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
            color: uMatriks.theme.palette.normal.backgroundText
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
                color: uMatriks.theme.palette.normal.backgroundTertiaryText
                font.pointSize: units.gu(0.9)
            }
            Text {
                id: dashlabel
                text: " - "
                color: uMatriks.theme.palette.normal.backgroundTertiaryText
                font.pointSize: units.gu(0.9)
            }
            Text {
                id: authorlabel
                text: eventType == "message" ? author : "***"
                color: uMatriks.theme.palette.normal.backgroundTertiaryText
                font.pointSize: units.gu(0.9)
            }
        }

        function checkForLink()
        {
            if (content.indexOf("https://") !== -1 || content.indexOf("http://") !== -1)
            {
                if((content.indexOf(".png") !== -1 || content.indexOf(".jpg") !== -1 || content.indexOf(".gif") !== -1))
                {
                    var start = content.indexOf("https://") !== -1 ? content.indexOf("https://") : content.indexOf("http://");
                    var end;
                    var url;
                    if(content.indexOf(".gif") !== -1)
                    {
                        end = content.indexOf(".gif");
                        url = content.slice(start, end + 4);
                        contentAnimatedImage.source = url;
                        contentAnimatedImage.visible = true;
                        contentAnimatedImage.anchors.top = contentlabel.bottom;
                        rect.height += contentAnimatedImage.height;
                    }
                    else
                    {
                        end = content.indexOf(".png") !== -1 ? content.indexOf(".png") : content.indexOf(".jpg");
                        url = content.slice(start, end + 4);
                        contentImage.source = url;
                        contentImage.visible = true;
                        contentImage.anchors.top = contentlabel.bottom;
                        rect.height += contentImage.height;
                    }
                }
                contentlabel.text = Utils.checkForLink(content);
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
                avatarImg.source = avatar
                avatarMask.visible = true
            } else {
                avatarImg.visible = false
                avatarMask.visible = false
                avatarText.visible = true

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
            rect.color = uMatriks.theme.palette.normal.background
            rect.border.width = 0
            contentlabel.color = uMatriks.theme.palette.normal.backgroundTertiaryText
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

