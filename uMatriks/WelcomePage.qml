import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id:page

    property int pagenumber


    Component.onCompleted: setPage (0)

    Column{
        id: introductionPage
        anchors.fill: parent
        anchors.margin: units.gu(2)
        spacing: units.gu(2)
        Label{
            width: parent.width
            wrapMode: Text.Wrap
            text: i18n.tr ("Welcome to uMatriks!<br/>\
            <br/>\
            uMatriks is a program that allows you to use the Matrix network.")
        }
    }

    Column{
        id: identityPage
        visible: false
        anchors.fill: parent
        anchors.margin: units.gu(2)
        spacing: units.gu(2)

        Label{
            width: parent.width
            wrapMode: Text.Wrap
            text: i18n.tr ("To use uMatriks, you need to login with your matrix <i>user</i>.")
        }

        Label{
            width: parent.width
            wrapMode: Text.Wrap
            text: i18n.tr ("Matrix ID:")
        }

        TextField {
            width: parent.width
            id: userNameFieldkk
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            validator: RegExpValidator { regExp: /[A-Za-z][A-Za-z0-9\[\]\\`_\-^{|}]*/ }
            // TRANSLATORS: Example nickname
            placeholderText: i18n.tr ("chattyman")
        }

    }


}
