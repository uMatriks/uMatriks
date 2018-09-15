#ifndef PUSH_HELPER_H
#define PUSH_HELPER_H

#include <QObject>
#include <QJsonObject>
#include "pushclient.h"

class PushHelper : public QObject {
    Q_OBJECT

public:
    PushHelper(const QString appId, const QString infile, const QString outfile, QObject *parent = 0);
    ~PushHelper() = default;
    void process();

Q_SIGNALS:
    void done();

public Q_SLOTS:
    void notificationDismissed();

protected:
    QJsonObject readPushMessage(const QString &filename);
    void writePostalMessage(const QJsonObject &postalMessage, const QString &filename);
    void dismissNotification(const QString &tag);
    QJsonObject pushToPostalMessage(const QJsonObject &push, QString &tag);

private:
    PushClient mPushClient;
    QString mInfile;
    QString mOutfile;
    QJsonObject mPostalMessage;
};

#endif
