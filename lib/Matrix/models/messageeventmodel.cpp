/******************************************************************************
 * Copyright (C) 2015 Felix Rohrbach <kde@fxrh.de>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#include "messageeventmodel.h"

#include <algorithm>
#include <QtCore/QRegularExpression>
#include <QtCore/QDebug>
#include <QPixmap>
#include <QBuffer>

#include "libqmatrixclient/connection.h"
#include "libqmatrixclient/room.h"
#include "libqmatrixclient/user.h"
#include "libqmatrixclient/events/event.h"
#include "libqmatrixclient/events/roommessageevent.h"
#include "libqmatrixclient/events/roommemberevent.h"
#include "libqmatrixclient/events/simplestateevents.h"

using namespace QMatrixClient;

enum EventRoles {
    EventTypeRole = Qt::UserRole + 1,
    TimeRole,
    DateRole,
    AuthorRole,
    ContentRole,
    UserIdRole,
    AvatarRole,
    MsgTypeRole
};

QHash<int, QByteArray> MessageEventModel::roleNames() const
{
    QHash<int, QByteArray> roles = QAbstractItemModel::roleNames();
    roles[EventTypeRole] = "eventType";
    roles[TimeRole] = "time";
    roles[DateRole] = "date";
    roles[AuthorRole] = "author";
    roles[ContentRole] = "content";
    roles[UserIdRole] = "userId";
    roles[AvatarRole] = "avatar";
    return roles;
}

MessageEventModel::MessageEventModel(QObject* parent)
    : QAbstractListModel(parent)
{
    m_currentRoom = 0;
    m_connection = 0;
}

MessageEventModel::~MessageEventModel()
{
}

void MessageEventModel::changeRoom(Room* room)
{
    beginResetModel();
    if( m_currentRoom )
    {
        m_currentRoom->disconnect(this);
    }
    m_currentRoom = room;
    if( room )
    {
        connect( room, &Room::aboutToAddNewMessages,
                [=](const RoomEvents& events)
                {
                    beginInsertRows(QModelIndex(), 0, events.size() - 1);
                });
        connect( room, &Room::aboutToAddHistoricalMessages,
                [=](const RoomEvents& events)
                {
                    beginInsertRows(QModelIndex(),
                                    rowCount(), rowCount() + events.size() - 1);
                });
        connect( room, &Room::addedMessages,
                 this, &MessageEventModel::endInsertRows );
    }
    endResetModel();
}

void MessageEventModel::setConnection(Connection* connection)
{
    m_connection = connection;
}

int MessageEventModel::rowCount(const QModelIndex& parent) const
{
    if( !m_currentRoom || parent.isValid() )
        return 0;
    return m_currentRoom->messageEvents().size();
}

QVariant MessageEventModel::data(const QModelIndex& index, int role) const
{
    if( !m_currentRoom ||
            index.row() < 0 || index.row() >= m_currentRoom->messageEvents().size() )
        return QVariant();

    RoomEvent *event = (m_currentRoom->messageEvents().end() - index.row() - 1)->event();
    // FIXME: Rewind to the name that was at the time of this event

    QString senderName = m_currentRoom->roomMembername(event->senderId());

    if( role == Qt::DisplayRole )
    {
        if( event->type() == EventType::RoomMessage )
        {
            RoomMessageEvent* e = static_cast<RoomMessageEvent*>(event);
            return QString("%1: %2").arg(senderName, e->plainBody());
        }
        if( event->type() == EventType::RoomMember )
        {
            RoomMemberEvent* e = static_cast<RoomMemberEvent*>(event);
            switch( e->membership() )
            {
                case MembershipType::Join:
                    return QString("%1 (%2) joined the room").arg(e->displayName(), e->userId());
                case MembershipType::Leave:
                    return QString("%1 (%2) left the room").arg(e->displayName(), e->userId());
                case MembershipType::Ban:
                    return QString("%1 (%2) was banned from the room").arg(e->displayName(), e->userId());
                case MembershipType::Invite:
                    return QString("%1 (%2) was invited to the room").arg(e->displayName(), e->userId());
                case MembershipType::Knock:
                    return QString("%1 (%2) knocked").arg(e->displayName(), e->userId());
            }
        }
        if( event->type() == EventType::RoomAliases )
        {
            RoomAliasesEvent* e = static_cast<RoomAliasesEvent*>(event);
            return QString("Current aliases: %1").arg(e->aliases().join(", "));
        }
        if (event->type() == EventType::Typing)
            qDebug() << "Typing";
        return "Unknown Event";
    }

    if( role == Qt::ToolTipRole )
    {
        return event->originalJson();
    }

    if( role == EventTypeRole )
    {
        switch (event->type()) {
            case EventType::RoomMessage: {
                auto msgType = static_cast<RoomMessageEvent*>(event)->msgtype();
                if (msgType == MessageEventType::Image) {
                    return "image";
                }
                if (msgType == MessageEventType::Emote) {
                    return "message.emote";
                } else if (msgType == MessageEventType::Notice) {
                    return "message.notice";
                }
                return "message";
            }
            case EventType::RoomName:
            case EventType::RoomAliases:
            case EventType::RoomCanonicalAlias:
            case EventType::RoomTopic:
            case EventType::Typing:
            case EventType::Receipt:
                return "state";
            default:
                return "unknown";
        }
    }

    if( role == TimeRole )
    {
        return event->timestamp();
    }

    if( role == DateRole )
    {
        return event->timestamp().toLocalTime().date();
    }

    if( role == AuthorRole )
    {
        return senderName;
    }

    if (role == UserIdRole)
    {
        if( event->type() == EventType::RoomMessage )
        {
            RoomMessageEvent* e = static_cast<RoomMessageEvent*>(event);
            qDebug() << QString(e->senderId());
            return QString(e->senderId());
        }
        return QVariant();
    }

    if (role == AvatarRole)
    {
        if( event->type() == EventType::RoomMessage )
        {
            RoomMessageEvent* e = static_cast<RoomMessageEvent*>(event);
            for (int i = 0; i < m_currentRoom->users().size(); i++){
                 if (e->senderId() ==  m_currentRoom->users()[i]->id()){
                     QPixmap p = m_currentRoom->users()[i]->avatar(500,500);
                     QByteArray bArr;
                     QBuffer buff(&bArr);
                     p.save(&buff, "JPEG");

                     QString image("data:image/jpg;base64,");
                     image.append(QString::fromLatin1(bArr.toBase64().data()));
                     return image;
                 }
            }
        }
       return QVariant();
    }

    if( role == ContentRole )
    {
        if( event->type() == EventType::RoomMessage )
        {
            auto e = static_cast<RoomMessageEvent*>(event);
            switch (e->msgtype()) {
                case MessageEventType::Image: {
                    auto content = static_cast<const MessageEventContent::ImageContent*>(e->content());
                    return QUrl("image://mtx/" + content->url.host() + content->url.path());
                    break;
                }
                default:
                    return e->plainBody();
                    break;
            }
        }
        if( event->type() == EventType::RoomMember )
        {
            RoomMemberEvent* e = static_cast<RoomMemberEvent*>(event);
            switch( e->membership() )
            {
                case MembershipType::Join:
                    return QString("%1 (%2) joined the room").arg(e->displayName(), e->userId());
                case MembershipType::Leave:
                    return QString("%1 (%2) left the room").arg(e->displayName(), e->userId());
                case MembershipType::Ban:
                    return QString("%1 (%2) was banned from the room").arg(e->displayName(), e->userId());
                case MembershipType::Invite:
                    return QString("%1 (%2) was invited to the room").arg(e->displayName(), e->userId());
                case MembershipType::Knock:
                    return QString("%1 (%2) knocked").arg(e->displayName(), e->userId());
            }
        }
        if( event->type() == EventType::RoomAliases )
        {
            RoomAliasesEvent* e = static_cast<RoomAliasesEvent*>(event);
            return QString("Current aliases: %1").arg(e->aliases().join(", "));
        }
        if( event->type() == EventType::Unknown )
        {
            return "Unknown Event: ";  // + e->typeString() + "(" + e->content();
        }
    }
    return QVariant();
}

