import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.0 as ListItems
import Ubuntu.Content 1.1


Page {
    id: sharePage
    title: "Share File to..."

    property string link
    property string title
    property alias contentType: sourcePicker.contentType

    // Content Peer
    property list<ContentItem> importItems
    property var activeTransfer

    Component {
        id: itemTemplate
        ContentItem {}
    }

    ContentPeerPicker {
        id: sourcePicker
        contentType: ContentType.Pictures
        handler: ContentHandler.Share

        showTitle: false

        onPeerSelected: {
            console.log('Sharing:'+link)
            activeTransfer = sourcePicker.peer.request()
            var results = [itemTemplate.createObject(sharePage, {"url": sharePage.link})];

            console.log("Items: "+results)
            if (activeTransfer !== null) {
                activeTransfer.items = results
                activeTransfer.state = ContentTransfer.Charged;
            }

            pageStack.pop()
        }

        onCancelPressed: {
            pageStack.pop()
        }

        Component.onCompleted: {
            console.log("Completed ....")
            // // HACK! Hackity hack hack. Bad!
            // sourcePicker.children[0].color = uReadIt.currentTheme.backgroundColor
            // sourcePicker.children[4].color = uReadIt.currentTheme.shareBackgroundColor
        }
    }

    ContentTransferHint {
        id: importHint
        anchors.fill: parent
        activeTransfer: sharePage.activeTransfer
    }



}
