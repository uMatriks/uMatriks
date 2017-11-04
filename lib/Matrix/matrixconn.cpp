#include "matrixconn.h"

MatrixConn::MatrixConn(QObject *parent) : QObject(parent)
{

}

QMatrixClient::Connection *MatrixConn::createConnection(const QUrl &server)
{
    return new QMatrixClient::Connection(server);

}
