#include <QQuickImageProvider>
#include "lib/connection.h"

#ifndef AVATARPROVIDER_H
#define AVATARPROVIDER_H


class AvatarProvider : public QQuickImageProvider
{
public:
    explicit AvatarProvider(QMatrixClient::Connection* conn);
    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize);

private:
    QMatrixClient::Connection* connection;
};

#endif // AVATARPROVIDER_H
