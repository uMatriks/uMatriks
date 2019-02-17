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
import QtGraphicalEffects 1.0
import Ubuntu.Components.Popups 1.3
import Matrix 1.0
import '../utils.js' as Utils

Item {
    id: chatBubble

    height: Math.max(units.gu(6), rect.height)

    property var room: null
    property var connection: null

    function checkForLink(content) {
        if (content.indexOf("https://") !== -1 || content.indexOf("http://") !== -1) {
            if((content.indexOf(".png") !== -1 || content.indexOf(".jpg") !== -1 || content.indexOf(".gif") !== -1)) {
                var start = content.indexOf("https://") !== -1 ? content.indexOf("https://") : content.indexOf("http://");
                var end;
                var url;
                if(content.indexOf(".gif") !== -1) {
                    end = content.indexOf(".gif");
                    url = content.slice(start, end + 4);
                    contentAnimatedImage.source = url;
                    contentAnimatedImage.visible = true;
                    rect.height += contentAnimatedImage.height;
                }
                else {
                    end = content.indexOf(".png") !== -1 ? content.indexOf(".png") : content.indexOf(".jpg");
                    url = content.slice(start, end + 4);
                    contentImage.source = url;
                    contentImage.visible = true;
                    rect.height += contentImage.height;
                }
            }
            contentlabel.text = Utils.checkForLink(content);
        }
    }

    DialogDownload {
        id: dialogDownload
        property var current: null
        property var downloadButton: null
        property var filename: null
        property var downloadUrl: null
    }

    Rectangle {
        id: avatarIcon
        height: units.gu(6)
        anchors.top: chatBubble.top
        width: height
        radius: height/2
        anchors.margins: units.gu(0.5)
        clip: true
        border.color: uMatriks.theme.palette.normal.overlayText
        color: uMatriks.theme.palette.normal.background

        Image {
            id: avatarImg
            anchors.fill: parent
            visible: false
            sourceSize.width: 16
            sourceSize.height: 16
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
        height: height
        anchors.margins: {
            right: units.gu(1)
            left: units.gu(1)
        }
        border.color: uMatriks.theme.palette.normal.raisedSecondaryText
        border.width: 1
        radius: 8
        color: uMatriks.theme.palette.normal.background

        Text {
            id: contentlabel
            text: eventType == "state" || eventType == "emote" ?
                      "* " + author.displayName + " " + display :
                  eventType != "other" ? display : "***"
            wrapMode: Text.Wrap
            font.pointSize: units.gu(1.5)
            font.italic: eventType == ["other", "emote", "state"].indexOf(eventType) >= 0 ? true : false
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: {
                top: units.gu(1)
                left: units.gu(1)
                bottom: units.gu(1)
            }
            color: uMatriks.theme.palette.normal.backgroundText
            linkColor: "blue"
            textFormat: Text.RichText
            onLinkActivated: Qt.openUrlExternally(link)
        }

        Image {
            id: contentImage
            visible: false
            anchors.left: parent.left
            anchors.top: contentlabel.visible ? contentlabel.bottom : undefined
            anchors.margins: {
                top: units.gu(1)
                left: units.gu(1)
                bottom: units.gu(1)
            }
            fillMode: Image.PreserveAspectFit
            height: units.gu(20)
            width: height
        }

        AnimatedImage {
            id: contentAnimatedImage
            visible: false
            anchors.left: parent.left
            anchors.top: contentlabel.visible ? contentlabel.bottom : undefined
            anchors.margins: {
                top: units.gu(1)
                left: units.gu(1)
                bottom: units.gu(1)
            }
            fillMode: Image.PreserveAspectFit
            height: units.gu(20)
            width: height
        }

        Button {
            id: downloadButton
            visible: false
            text: i18n.tr("Download")
            anchors.left: parent.left
            anchors.margins: {
                top: units.gu(1)
                left: units.gu(1)
                bottom: units.gu(1)
            }
            onClicked: {
                var downloadUrl = room.urlToDownload(eventId)
                console.log("Download Url: " + downloadUrl)

                dialogDownload.downloadButton = downloadButton
                dialogDownload.filename = display
                dialogDownload.downloadUrl = downloadUrl
                dialogDownload.current = PopupUtils.open(dialogDownload, uMatriks)
            }
        }

        Row {
            id: innerRect
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: {
                top: units.gu(1)
                left: units.gu(1)
                bottom: units.gu(1)
            }

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
                horizontalAlignment: if( ["other", "emote", "state"].indexOf(eventType) >= 0 ) { Text.AlignRight }
                elide: Text.ElideRight
                text: eventType == "state" || eventType == "emote" ?
                          "* " + author.displayName :
                      eventType != "other" ? author.displayName : "***"
                color: uMatriks.theme.palette.normal.backgroundTertiaryText
                font.pointSize: units.gu(0.9)
            }
        }

        Component.onCompleted: {
            if (["notice", "emote", "message", "file"].indexOf(eventType) >= 0){
                contentlabel.width = Math.min(contentlabel.contentWidth, chatBubble.width - avatarIcon.width - 40 - 30)
                contentlabel.height = contentlabel.contentHeight
                width = Math.max(contentlabel.width, innerRect.width) + 30
                rect.height = Math.max(contentlabel.height + innerRect.height + 40, avatarIcon.height)
                if (eventType == "file") {
                    downloadButton.anchors.top = contentlabel.bottom
                    downloadButton.visible = true;
                    rect.height += downloadButton.height + 20
                } else {
                    checkForLink(content);
                }
            } else if (eventType === "image") {
                contentImage.width = chatBubble.width - avatarIcon.width - 40 - 30
                width = Math.max(contentImage.width, innerRect.width) + 30
                rect.height = Math.max(contentImage.height + innerRect.height + 40, avatarIcon.height)
                rect.height += downloadButton.height + 20
                downloadButton.anchors.top = contentImage.bottom
                downloadButton.visible = true;
            }
            height = rect.height
            // console.log("event: " + eventType + " content " + content)
        }
    }

    Component.onCompleted: {
        if (author.avatarMediaId) {
            avatarImg.source = "image://mtx/" + author.avatarMediaId
            console.log("avatar Url: " + avatarImg.source)
            avatarMask.visible = true
        } else {
            avatarImg.visible = false
            avatarMask.visible = false
            avatarText.visible = true
        }

        if (author && author.id === connection.localUserId) {
            avatarIcon.anchors.right = chatBubble.right
            rect.anchors.right = avatarIcon.left
            rect.color = "#9E7D96"
            contentlabel.color = "white"
            timelabel.color = UbuntuColors.lightGrey
            authorlabel.color = UbuntuColors.lightGrey
            dashlabel.color = UbuntuColors.lightGrey
        } else {
            avatarIcon.anchors.left = chatBubble.left
            rect.anchors.left = avatarIcon.right
        }

        if (eventType === "image") {
            contentImage.sourceSize = "1000x1000"
            contentImage.source = content;
            contentImage.visible = true;
            contentlabel.visible = false;
        }
        if (["other", "state"].indexOf(eventType) >= 0 ){
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

