#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QLocale>
#include <QDebug>
#include <QQmlEngine>
#include <QQmlContext>
#include <QStandardPaths>
#include <QSqlDatabase>
#include <QSqlError>
#include <QDir>
#include <QFontDatabase>
#include "qdownloader.h"
#include "markermodel.h"
#include "sqlconversationmodel.h"
#include "sqlcontactmodel.h"
#include "qimageconverter.h"

static void connectToDatabase()
{
    QSqlDatabase database = QSqlDatabase::database();
    if (!database.isValid()) {
        database = QSqlDatabase::addDatabase("QSQLITE");
        if (!database.isValid())
            qFatal("Cannot add database: %s", qPrintable(database.lastError().text()));
    }

    const QDir writeDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (!writeDir.mkpath("."))
        qFatal("Failed to create writable directory at %s", qPrintable(writeDir.absolutePath()));

    // Ensure that we have a writable location on all devices.
    const QString fileName = writeDir.absolutePath() + "/chat-database.sqlite3";
    //QFile::remove(fileName);
    qDebug() << "DB FILENAME: " << fileName;
    // When using the SQLite driver, open() will create the SQLite database if it doesn't exist.
    database.setDatabaseName(fileName);
    if (!database.open()) {
        qFatal("Cannot open database: %s", qPrintable(database.lastError().text()));
        QFile::remove(fileName);
    }
}

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

    MarkerModel model;
    engine.rootContext()->setContextProperty("markerModel", &model);

    connectToDatabase();

    SqlContactModel contact_model;
    engine.rootContext()->setContextProperty("contactModel", &contact_model);

    SqlConversationModel conversation_model;
    engine.rootContext()->setContextProperty("conversationModel", &conversation_model);


    qmlRegisterType<QImageConverter>("Cometogether.converter", 1, 0, "BackendImageConverter");

    qmlRegisterType<QDownloader>("Cometogether.downloader", 1, 0, "BackendFileDonwloader");


    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
