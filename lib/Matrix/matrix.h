#ifndef MATRIX_PLUGIN_H
#define MATRIX_PLUGIN_H

#include <QtQml/QQmlEngine>
#include <QtQml/QQmlExtensionPlugin>

class MatrixPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri);
    void initializeEngine(QQmlEngine *engine, const char *uri);
};
#endif // MATRIX_PLUGIN_H
