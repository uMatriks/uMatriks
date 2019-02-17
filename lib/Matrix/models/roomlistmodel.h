/**************************************************************************
 *                                                                        *
 * Copyright (C) 2016 Felix Rohrbach <kde@fxrh.de>                        *
 *                                                                        *
 * This program is free software; you can redistribute it and/or          *
 * modify it under the terms of the GNU General Public License            *
 * as published by the Free Software Foundation; either version 3         *
 * of the License, or (at your option) any later version.                 *
 *                                                                        *
 * This program is distributed in the hope that it will be useful,        *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          *
 * GNU General Public License for more details.                           *
 *                                                                        *
 * You should have received a copy of the GNU General Public License      *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.  *
 *                                                                        *
 **************************************************************************/

#pragma once

#include <QtCore/QAbstractListModel>

namespace QMatrixClient
{
    class Connection;
    class Room;
}

class RoomListModel: public QAbstractListModel
{
        Q_OBJECT
        // using breaks with Q_INVOKABLE
        // anyway explicit is better than implicit
    public:
        enum EventRoles {
          Name = Qt::UserRole + 1,
          Avatar,
          RoomEventState,
          UnreadCount,
          LastEvent
        };
        explicit RoomListModel(QObject* parent = nullptr);

        Q_INVOKABLE void addConnection(QMatrixClient::Connection* connection);
        void deleteConnection(QMatrixClient::Connection* connection);
        Q_INVOKABLE QMatrixClient::Room* roomAt(int row);

        QVariant data(const QModelIndex& index, int role) const override;
        int rowCount(const QModelIndex& parent) const override;

        QHash<int, QByteArray> roleNames() const override;

    private slots:
        void displaynameChanged(QMatrixClient::Room* room);
        void unreadMessagesChanged(QMatrixClient::Room* room);
        void refresh(QMatrixClient::Room* room, const QVector<int>& roles = {});

        void updateRoom(QMatrixClient::Room* room,
                        QMatrixClient::Room* prev);
        void deleteRoom(QMatrixClient::Room* room);

    signals:
        // XXX used for updating unread marer
        void roomDataChangedEvent(int index);

    private:
        QList<QMatrixClient::Connection*> m_connections;
        QList<QMatrixClient::Room*> m_rooms;

        void doAddRoom(QMatrixClient::Room* r);
        void connectRoomSignals(QMatrixClient::Room* room);
};
