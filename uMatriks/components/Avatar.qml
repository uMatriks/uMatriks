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
import Matrix 1.0
import '../utils.js' as Utils

Item {
  id: avatarRoot

  property string source: ""
  property string user: ""

  Image {
      id: roomAvatar
      anchors.fill: parent
      source: avatarRoot.source
      sourceSize.width: width
      sourceSize.height: height
  }

  Rectangle {
    id: dummyAvatar
    anchors.fill: parent
    color: stringToColor(user)
    radius: width / 2
    visible: roomAvatar.status != Image.Ready

    Label {
      anchors.centerIn: parent
      color: "white"
      text: getFirstLetter(user)
      font.pixelSize: parent.width / 2
      font.bold: true
    }
  }

  function getFirstLetter(user) {
      if (user.length >= 1)
        return user[0].toUpperCase();
      return "U";
  }

  function stringToColor(str) {
    var hash = 0;
    var color = '#';

    for (var i = 0; i < str.length; i++) {
        hash = str.charCodeAt(i) + ((hash << 5) - hash);
    }
    for (var j = 0; j < 3; j++) {
        var value = (hash >> (j * 8)) & 0xFF;
        color += ('00' + value.toString(16)).substr(-2);
    }
    return color;
  }

}
