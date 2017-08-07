#ifndef IMAGEPROVIDER_H
#define IMAGEPROVIDER_H

#include <QtQuick/QQuickImageProvider>
#include <QtCore/QMutex>
#include <QtCore/QWaitCondition>

namespace QMatrixClient {
    class Connection;
}

class ImageProvider: public QObject, public QQuickImageProvider
{
        Q_OBJECT
    public:
        explicit ImageProvider(QMatrixClient::Connection* connection);

        QPixmap requestPixmap(const QString& id, QSize* size,
                              const QSize& requestedSize) override;

        void setConnection(const QMatrixClient::Connection* connection);

    private:
        Q_INVOKABLE void doRequest(QString id, QSize requestedSize,
                                   QPixmap* pixmap, QWaitCondition* condition);

        const QMatrixClient::Connection* m_connection;
        QMutex m_mutex;
};

Q_DECLARE_METATYPE(QPixmap*)
Q_DECLARE_METATYPE(QWaitCondition*)

#endif // IMAGEPROVIDER_H
