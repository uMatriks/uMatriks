#pragma once

#include <QObject>

#include "connection.h"

class MatrixHelper : public QObject
{
    Q_OBJECT
    public:
        explicit MatrixHelper(QObject *parent = 0);

        Q_INVOKABLE QMatrixClient::Connection* createConnection(const QUrl &server);
        Q_INVOKABLE void moveToDownloads(const QString& path);

    signals:
        void setImageProviderConnection(QMatrixClient::Connection* connection);
};
