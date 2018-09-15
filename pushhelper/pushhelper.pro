TEMPLATE = app
TARGET = push
CONFIG += c++14 
QT -= gui
QT += dbus widgets
INCLUDEPATH += .

MOC_DIR = mocs
OBJECTS_DIR = objs

HEADERS += pushclient.h pushhelper.h
SOURCES += push.cpp pushclient.cpp pushhelper.cpp
OTHER += apparmor-push.json push-helper.json

other.files += $$OTHER
other.path = /

target.path = /

INSTALLS += target other
