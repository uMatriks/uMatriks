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
  id: root

  height: isEvent ? chatEvent.height : chatBubble.height

  property var room: null
  property var connection: null
  property bool isEvent: ["other", "emote", "state"].indexOf(eventType) >= 0

  ChatEvent {
    id: chatEvent
    visible: isEvent
    avatar: "image://mtx/" + author.avatarMediaId
    user: author.displayName
    text: display
  }

  ChatBubble {
    width: parent.width
    id: chatBubble
    visible: !isEvent
    room: root.room
    connection: root.connection
  }
}
