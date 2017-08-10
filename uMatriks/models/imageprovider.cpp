#include "imageprovider.h"

#include "libqmatrixclient/connection.h"
#include "libqmatrixclient/jobs/mediathumbnailjob.h"

#include <QtCore/QDebug>

ImageProvider::ImageProvider(QMatrixClient::Connection* connection)
    : QQuickImageProvider(QQmlImageProviderBase::Pixmap, QQmlImageProviderBase::ForceAsynchronousImageLoading)
    , m_connection(connection)
{
    qRegisterMetaType<QPixmap*>();
    qRegisterMetaType<QWaitCondition*>();
}

QPixmap ImageProvider::requestPixmap(const QString& id,
                                     QSize* size, const QSize& requestedSize)
{
    QMutexLocker locker(&m_mutex);
    qDebug() << "ImageProvider::requestPixmap:" << id;

    QWaitCondition condition;
    QPixmap result;
    QMetaObject::invokeMethod(this, "doRequest", Qt::QueuedConnection,
                              Q_ARG(QString, id), Q_ARG(QSize, requestedSize),
                              Q_ARG(QPixmap*, &result),
                              Q_ARG(QWaitCondition*, &condition));
    condition.wait(&m_mutex);

    if( size != nullptr )
    {
        *size = result.size();
    }

    return result;
}

void ImageProvider::setConnection(const QMatrixClient::Connection* connection)
{
    QMutexLocker locker(&m_mutex);

    m_connection = connection;
}

void ImageProvider::doRequest(QString id, QSize requestedSize, QPixmap* pixmap,
                              QWaitCondition* condition)
{
    Q_ASSERT(pixmap);
    Q_ASSERT(condition);
    QMutexLocker locker(&m_mutex);
    if( !m_connection )
    {
        qDebug() << "ImageProvider::requestPixmap: no connection!";
        *pixmap = QPixmap();
        condition->wakeAll();
        return;
    }

    auto job = m_connection->getThumbnail(QUrl(id), requestedSize.expandedTo({100,100}));
    connect( job, &QMatrixClient::MediaThumbnailJob::success, this, [=]()
    {
        // No need to lock because we don't deal with the ImageProvider state
        qDebug() << "gotImage";

        *pixmap =
            job->thumbnail().scaled(requestedSize,
                                    Qt::KeepAspectRatio, Qt::SmoothTransformation);
        condition->wakeAll();
    } );
}
