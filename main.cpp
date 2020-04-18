#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QLocale>
#include <QDebug>
#include <QQmlEngine>
#include "qdownloader.h"

int main(int argc, char *argv[])
{

    //QLocale::setDefault(QLocale::system());
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    qDebug() << engine.offlineStoragePath();
    const QUrl url(QStringLiteral("qrc:/main.qml"));

    qmlRegisterType<QDownloader>("Cometogether.downloader", 1, 0, "BackendFileDonwloader");
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
