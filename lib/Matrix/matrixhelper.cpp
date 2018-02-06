#include <QtCore/QDebug>
#include <QtCore/QDir>
#include <QtCore/QFile>
#include <QtCore/QFileInfo>
#include <QtCore/QStandardPaths>

#include "matrixhelper.h"

MatrixHelper::MatrixHelper(QObject *parent) : QObject(parent) {}

QMatrixClient::Connection *MatrixHelper::createConnection(const QUrl &server)
{
    auto conn = new QMatrixClient::Connection(server);
    emit setImageProviderConnection(conn);
    return conn;
}

void MatrixHelper::moveToDownloads(const QString& path)
{
    QFile file(path);
    if (file.exists()) {
        QFileInfo fi(path);

        // Move file to XDG Downloads folder
        QDir dir(QStandardPaths::writableLocation(QStandardPaths::DownloadLocation));
        if (!dir.exists()) {
            QDir::root().mkpath(dir.absolutePath());
        }
        QString baseName = fi.baseName();
        QString suffix = fi.completeSuffix();
        QString destination = dir.absoluteFilePath(QString("%1.%2").arg(baseName, suffix));
        // Avoid filename collision by automatically inserting an incremented
        // number into the filename if the original name already exists.
        int append = 1;
        while (QFile::exists(destination)) {
            destination = dir.absoluteFilePath(QString("%1.%2.%3").arg(baseName, QString::number(append++), suffix));
        }
        auto ret = file.rename(destination);
        if (!ret) {
            qWarning() << "Failed moving file from" << path << "to" << destination << "reason: " << ret;
        }

    } else {
        qWarning() << "Download not found:" << path;
    }
}
