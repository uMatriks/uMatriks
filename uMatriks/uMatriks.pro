TEMPLATE = aux
TARGET = uMatriks

RESOURCES += uMatriks.qrc

QML_FILES += $$files(*.qml,false) \
             $$files(*.js,true)

CONF_FILES +=  uMatriks.apparmor

AP_TEST_FILES += tests/autopilot/run \
                 $$files(tests/*.py,true)

#show all the files in QtCreator
OTHER_FILES += $${CONF_FILES} \
               $${QML_FILES} \
               $${AP_TEST_FILES} \
               uMatriks.desktop


#specify where the qml/js files are installed to
qml_files.path = /uMatriks
qml_files.files += $${QML_FILES}

qml_components.path = /uMatriks
qml_components.files += components

qml_resources.path = /uMatriks
qml_resources.files += resources

#specify where the config files are installed to
config_files.path = /uMatriks
config_files.files += $${CONF_FILES}

content_hub.path = /uMatriks
content_hub.files += content-hub.json

#install the desktop file, a translated version is
#automatically created in the build directory
desktop_file.path = /uMatriks
desktop_file.files = $$OUT_PWD/uMatriks.desktop
desktop_file.CONFIG += no_check_exist

INSTALLS+=config_files qml_files qml_components desktop_file qml_resources content_hub
