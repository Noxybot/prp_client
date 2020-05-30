#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QLocale>
#include <QDebug>
#include <QQmlEngine>
#include <QQmlContext>
#include <QStandardPaths>
#include <QDir>
#include <QFontDatabase>
#include "qdownloader.h"
#include "markermodel.h"
#include "sqlconversationmodel.h"
#include "sqlcontactmodel.h"
#include "qimageconverter.h"
#include "markerimageprovider.h"
#include "contactimageprovider.h"


static QString g_server_ip {"178.150.141.36:1337"};
int main(int argc, char *argv[])
{

    //QLocale::setDefault(QLocale::system());
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    app.setOrganizationName("Come Together");
    app.setOrganizationDomain("cometogether.com");
    app.setApplicationName("Come Together");

    QQmlApplicationEngine engine;
    qDebug() << engine.offlineStoragePath();
    QFontDatabase fontDB;
    auto ret = fontDB.addApplicationFont(":/fontawesome-free-5.13.0-desktop/otfs/Font Awesome 5 Free-Regular-400.otf");
    if (ret == -1)
        qDebug() << "font1 could not be loaded";
    ret = fontDB.addApplicationFont(":/fontawesome-free-5.13.0-desktop/otfs/Font Awesome 5 Brands-Regular-400.otf");
    if (ret == -1)
        qDebug() << "font2 could not be loaded";
    ret = fontDB.addApplicationFont(":/fontawesome-free-5.13.0-desktop/otfs/Font Awesome 5 Free-Solid-900.otf");
    if (ret == -1)
        qDebug() << "font3 could not be loaded";
    const QUrl url(QStringLiteral("qrc:/main.qml"));

    MarkerModel marker_model;
    engine.rootContext()->setContextProperty("markerModel", &marker_model);

    connectToDatabase();

    auto contact_model = std::make_shared<SqlContactModel>();
    engine.rootContext()->setContextProperty("contactModel", contact_model.get());

    SqlConversationModel conversation_model;
    engine.rootContext()->setContextProperty("conversationModel", &conversation_model);


    qmlRegisterType<QImageConverter>("Cometogether.converter", 1, 0, "BackendImageConverter");

    qmlRegisterType<QDownloader>("Cometogether.downloader", 1, 0, "BackendFileDonwloader");

    auto  marker_provider = new MarkerImageProvider{g_server_ip};
    QObject::connect(&marker_model, &MarkerModel::markerDeleted, marker_provider, &MarkerImageProvider::markerDeleted);
    engine.addImageProvider(QLatin1String("marker_image_provider"), marker_provider);


    auto  contact_provider = new ContactImageProvider {g_server_ip, contact_model };
    engine.addImageProvider(QLatin1String("contact_image_provider"),
                            contact_provider);
    engine.rootContext()->setContextProperty("contact_image_provider", contact_provider);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
