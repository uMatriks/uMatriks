#include "matrixconn.h"

MatrixConn::MatrixConn(QObject *parent) : QObject(parent)
{

}

QMatrixClient::Connection *MatrixConn::createConnection(const QUrl &server)
{
    auto conn = new QMatrixClient::Connection(server);
    emit setImageProviderConnection(conn);
    return conn;
}
