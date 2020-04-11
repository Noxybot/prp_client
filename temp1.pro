QT += quick qml network positioning location
QT += quickcontrols2

QT_FOR_CONFIG += location-private
qtConfig(geoservices_mapboxgl): QT += sql opengl
qtConfig(geoservices_osm): QT += concurrent

CONFIG += c++11

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS
android: include(C:\Qt\Android_stuff\android_openssl\openssl.pri)
# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0
#include (D:\Projects\temp1\mapbox-gl-qml\mapbox-gl-qml.pri)
SOURCES += \
        main.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    main.qml \
    profile.qml \
    qml/main.qml \
    qml/profile.qml \
    qml_main/main.qml \
    qml_main/profile.qml

#update qml
qml_scenes.depends = $$PWD/resources/main.qml $$PWD/resources/profe.qml
qml_scenes.commands =
QMAKE_EXTRA_TARGETS += qml_scenes

ANDROID_EXTRA_LIBS = C:/Qt/Android_stuff/android_openssl/latest/arm/libcrypto_1_1.so C:/Qt/Android_stuff/android_openssl/latest/arm/libssl_1_1.so C:/Qt/Android_stuff/android_openssl/latest/arm64/libcrypto_1_1.so C:/Qt/Android_stuff/android_openssl/latest/arm64/libssl_1_1.so
