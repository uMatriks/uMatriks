import QtQuick 2.4
import QtTest 1.0
import Ubuntu.Test 1.0
import "../../"
// See more details at https://api-docs.ubports.com/index.html

Item {

    width: units.gu(100)
    height: units.gu(75)

    // The objects
    Main {
        id: main
    }

    UbuntuTestCase {
        name: "MainTestCase"

        when: windowShown

        function init() {
            var login = findChild(main, "login");
            compare("[ uMatriks ]", login.header.title);
        }

        // function test_clickButtonMustChangeLabel() {
        //     var button = findChild(main, "button");
        //     var buttonCenter = centerOf(button)
        //     mouseClick(button, buttonCenter.x, buttonCenter.y);
        //     var label = findChild(main, "label");
        //     // See the tryCompare method documentation at https://developer.ubuntu.com/api/qml/sdk-14.10/QtTest.TestCase/#tryCompare-method
        //     tryCompare(label, "text", "..world!", 1);
        // }
    }
}
