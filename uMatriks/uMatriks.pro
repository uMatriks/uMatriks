TEMPLATE = app
TARGET = uMatriks

load(ubuntu-click)

QT += qml quick

include(libqmatrixclient/libqmatrixclient.pri)

SOURCES += main.cpp \
    models/roomlistmodel.cpp \
    models/messageeventmodel.cpp \
    models/imageprovider.cpp \ #\
    matrixconn.cpp
#    models/avatarprovider.cpp

RESOURCES += uMatriks.qrc

QML_FILES += $$files(*.qml,true) \
             $$files(*.js,true)

CONF_FILES +=  uMatriks.apparmor \
               uMatriks.svg

AP_TEST_FILES += tests/autopilot/run \
                 $$files(tests/*.py,true)

#show all the files in QtCreator
OTHER_FILES += $${CONF_FILES} \
               $${QML_FILES} \
               $${AP_TEST_FILES} \
               uMatriks.desktop

#specify where the config files are installed to
config_files.path = /uMatriks
config_files.files += $${CONF_FILES}
INSTALLS+=config_files

#install the desktop file, a translated version is 
#automatically created in the build directory
desktop_file.path = /uMatriks
desktop_file.files = $$OUT_PWD/uMatriks.desktop
desktop_file.CONFIG += no_check_exist
INSTALLS+=desktop_file

# Default rules for deployment.
target.path = $${UBUNTU_CLICK_BINARY_PATH}
INSTALLS+=target

DISTFILES += \
    Login.qml \
    WelcomePage.qml \
    ChatRoom.qml \
    RoomList.qml \
    RoomView.qml \
    About.qml \
    Theme.qml \
    Main.qml \
    umatriks.svg

HEADERS += \
    models/roomlistmodel.h \
    models/messageeventmodel.h \
    models/imageprovider.h \
    models/avatarprovider.h \
    matrixconn.h
