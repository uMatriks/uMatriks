#pragma once

#include <QtQml/QQmlEngine>
#include <QtQml/QQmlExtensionPlugin>
#include "models/imageprovider.h"
#include "connection.h"
#include "room.h"
using namespace QMatrixClient;

class MatrixPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

    public:
        void registerTypes(const char *uri);
        void initializeEngine(QQmlEngine *engine, const char *uri);

    private:
        ImageProvider* img = nullptr;

    private slots:
        void setImageProviderConnection(Connection* connection);
};
