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

    header: PageHeader {
       id:_pageHeader
       title: roomView.title
       leadingActionBar.actions: [
           Action {
               iconName: "back"
               text: "Back"
               onTriggered: mainAdaptiveLayout.removePages(sharePage)
           }
       ]
    }

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

            mainAdaptiveLayout.removePages(sharePage)
        }

        onCancelPressed: {
            mainAdaptiveLayout.removePages(sharePage)
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
