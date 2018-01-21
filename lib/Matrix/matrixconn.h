#pragma once

#include <QObject>

#include "connection.h"

class MatrixConn : public QObject
{
    Q_OBJECT
    public:
        explicit MatrixConn(QObject *parent = 0);

        Q_INVOKABLE QMatrixClient::Connection* createConnection(const QUrl &server);

    signals:
        void setImageProviderConnection(QMatrixClient::Connection* connection);
};
