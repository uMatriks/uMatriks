#include "pushhelper.h"
#include <QApplication>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QStringList>


PushHelper::PushHelper(const QString appId, const QString infile, const QString outfile, QObject *parent) : QObject(parent),
    mInfile(infile), mOutfile(outfile)
{
    connect(&mPushClient, SIGNAL(persistentCleared()),
                    this, SLOT(notificationDismissed()));

    mPushClient.setAppId(appId);
    mPushClient.registerApp(appId);
}

void PushHelper::process() {
    QString tag = "";

    QJsonObject pushMessage = readPushMessage(mInfile);
    mPostalMessage = pushToPostalMessage(pushMessage, tag);
    if (!tag.isEmpty()) {
        dismissNotification(tag);
    }

    // persistentCleared not called!
    notificationDismissed();
}

void PushHelper::notificationDismissed() {
    writePostalMessage(mPostalMessage, mOutfile);
    Q_EMIT done(); // Why does this not work?
}

QJsonObject PushHelper::readPushMessage(const QString &filename) {
    QFile file(filename);
    file.open(QIODevice::ReadOnly | QIODevice::Text);

    QString val = file.readAll();
    file.close();
    return QJsonDocument::fromJson(val.toUtf8()).object();
}

void PushHelper::writePostalMessage(const QJsonObject &postalMessage, const QString &filename) {
    QFile out;
    out.setFileName(filename);
    out.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate);

    QTextStream(&out) << QJsonDocument(postalMessage).toJson();
    out.close();
}

void PushHelper::dismissNotification(const QString &tag) {
    QStringList tags;
    tags << tag;
    mPushClient.clearPersistent(tags);
}

QJsonObject PushHelper::pushToPostalMessage(const QJsonObject &push, QString &tag) {
    /**
     * For now only show a notification card for messages and call invites
     *
     * For anything else just return the original json in the `message` field to
     * be delivered to the app.
     */
    const QString type = push["type"].toString();
    if (type != QStringLiteral("m.room.message") && type != QStringLiteral("m.call.invite")) {
        return QJsonObject{
            {"message", push},
        };
    }

    // First try the sender displayname otherwise fallback
    // to the full length username type string thingy
    QString sender = push["sender_display_name"].toString();
    if (sender.isEmpty()) {
        sender = push["sender"].toString();
    }
    // Unread count
    const QJsonObject counts = push["counts"].toObject();
    const qint32 unread = qint32(counts["unread"].toInt());
    // Content object containing message body
    const QJsonObject content = push["content"].toObject();
    //The notification object to be passed to Postal
    QJsonObject notification{
        {"tag", tag},
        {"card", QJsonObject{
            {"summary", sender},
            {"body", content["body"].toString()},
            // For now the chat id is the push messages id. The app can then search the list of
            // delivered messages via PushClient::notificationsChanged(QStringList) in qml
            // TODO: come up with a url scheme to be able to launch to a specific view state
            {"actions", QJsonArray() << QString("matriks://chat/%1").arg(QString::number(push["id"].toInt()))},
            {"popup", true},
            {"persist", true},
        }},
        {"emblem-counter", QJsonObject{
            {"count", unread},
            {"unread", unread > 0},
        }},
        {"sound", true},
        {"vibrate", QJsonObject{
            {"pattern", QJsonArray() << 200 << 100},
            {"duration", 200},
            {"repeat", 2},
        }},
    };

    return QJsonObject{
        {"message", push}, // Include the original matrix push object to be delivered to the app
        {"notification", notification}
    };
}
