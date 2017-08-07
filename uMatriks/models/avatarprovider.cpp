#include "avatarprovider.h"
#include "lib/connection.h"
#include <QQuickImageProvider>

AvatarProvider::AvatarProvider(QMatrixClient::Connection* conn)
    : QQuickAsyncImageProvider(QQuickAsyncImageProvider::Pixmap),
      connection(conn)
{
}

AvatarProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{

}
