import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.DownloadManager 1.2


Component {
   Dialog {
      id: dialog
      title: "<b>%1</b>".arg(i18n.tr("Download"))

      Component.onCompleted: {
         console.log("Download popup filename: " + filename)
         console.log("Download popup url: " + downloadUrl)
         single.metadata.title = filename
         single.download(downloadUrl)
      }

      Label {
         wrapMode: Text.WordWrap
         text: filename
      }

      Button {
         text: i18n.tr("Cancel")
         onClicked: {
            single.cancel()
            console.log("Cancel");
            PopupUtils.close(current);
         }
      }

      ProgressBar {
         minimumValue: 0
         maximumValue: 100
         value: single.progress
         height: units.gu(0.5)

         anchors {
            left: parent.left
            right: parent.right
         }
      }

      SingleDownload {
         id: single
         autoStart: true
         metadata: Metadata {
            showInIndicator: true
         }

         onFinished: {
            downloadButton.enabled = false
            console.log('Downloaded to: '+path)
            mainAdaptiveLayout.addPageToCurrentColumn(mainAdaptiveLayout.primaryPage,Qt.resolvedUrl("../SharePage.qml"), {'link': path})
            PopupUtils.close(current);
         }
      }
   }
}
