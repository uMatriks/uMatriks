import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.3
import Ubuntu.Components.Popups 1.3
import Matrix 1.0


Page {
    id: memberList
    anchors.fill: parent
    visible: false

    property var members

    Column {
        id: memberListColumn

        anchors {
            fill: parent
            //topMargin: header.flickable ? 0 : header.height
        }

        ListView {
            id: membersListView
            model: memberList.members
            width: parent.width
            height: parent.height

            delegate: ListItem {
                height: memberListLayout.height + (divider.visible ? divider.height : 0)
                theme: ThemeSettings {
                    name: uMatriks.theme.name
                }

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
                                var popup = PopupUtils.open(warning, memberList);
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


