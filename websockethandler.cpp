#include "websockethandler.h"
#include <QJsonDocument>
#include "markermodel.h"

WebsocketHandler::WebsocketHandler(const QUrl& server_url, std::shared_ptr<MarkerModel> marker_model,
                                   std::shared_ptr<SqlContactModel> sql_contact_model,
                                   std::shared_ptr<SqlConversationModel> sql_conversaton_model)
    : m_marker_model(std::move(marker_model))
    , m_sql_contact_model(std::move(sql_contact_model))
    , m_sql_conversation_model(std::move(sql_conversaton_model))
{
    m_web_socket.open(server_url);
    QObject::connect(&m_web_socket, &QWebSocket::textMessageReceived, this, &WebsocketHandler::onTextMessageReceived);
}

void WebsocketHandler::onAboutToClose()
{
    qDebug()<<"aboutToClose\n";
}

void WebsocketHandler::onTextMessageReceived(const QString &message)
{
    QJsonDocument jsonResponse = QJsonDocument::fromJson(message.toUtf8());
    auto method = jsonResponse["method"];
    if (method == "draw_marker") {
        auto id = jsonResponse["id"].toInt();
        if (m_marker_model->containtsMarker(id)) {
            return;
        }
        MarkerModel::markerInfo marker_info;
        auto latitude = jsonResponse["latitude"].toDouble();
        auto longitude = jsonResponse["longitude"].toDouble();
        marker_info.m_coordinate = QGeoCoordinate(latitude, longitude);
        marker_info.m_creator_login = jsonResponse["creator_login"].toString();
        marker_info.m_name = jsonResponse["name"].toString();
        marker_info.m_category = jsonResponse["category"].toString();
        marker_info.m_subcategory = jsonResponse["subcategory"].toString();
        marker_info.m_from_time = jsonResponse["from_time"].toString();
        marker_info.m_to_time = jsonResponse["to_time"].toString();
        marker_info.m_creation_time = {};
        marker_info.m_expected_people_number = jsonResponse["expected_people_number"].toString();
        marker_info.m_expected_expenses = jsonResponse["expected_expenses"].toString();
        marker_info.m_description = jsonResponse["description"].toString();
        m_marker_model->addMarker(std::move(marker_info));
    }
    else if (method == "send_message"){
       // console.log("onTextMessageReceived: " + message)
        auto to_login = jsonResponse["to"].toString(); //todo: fix it
        auto from_login = jsonResponse["from"].toString();
        auto msg_text = jsonResponse["text"].toString();
        auto unix_time = jsonResponse["timestamp"].toInt();
        if (from_login == m_sql_contact_model->getCurrentUserLogin()){
            m_sql_conversation_model->sendMessage("Me", to_login, msg_text, unix_time);
            if (!m_sql_contact_model->userPresent(to_login))
                m_sql_contact_model->addContact(to_login, ""/*getDisplayNameByLogin(to_login)*/); //todo: change it
        }
        else {
            m_sql_conversation_model->sendMessage(from_login, "Me", msg_text, unix_time);
            auto dn = jsonResponse["from_dn"].toString();
            //todo: emit signal MessageArrived
            /*if(stack.currentItem.objectName !== "chatPage" && stack.currentItem.inConversationWithDN !== dn)
            {
                console.log("page " + stack.currentItem.objectName)
                console.log("name "+stack.currentItem.inConversationWithDN + " "+dn)
                popup_msg.text = msg_text
                popup_msg.login = from_login
                popup_msg.dn = dn
                popup_msg.dn_alias = dn
                popup_msg.img = "image://contact_image_provider/" + from_login
                popup_msg.open()
            }

*/
            if (!m_sql_contact_model->userPresent(from_login))
                m_sql_contact_model->addContact(from_login, dn);
        }
    }
    else if (method == "delete_marker"){
        auto marker_id = jsonResponse["id"].toInt();
        qDebug()<<"Deleting marker: " + QString::fromStdString(std::to_string(marker_id));
        m_marker_model->removeMarker(marker_id);
    }
    else if (method == "login_user"){
        auto login = jsonResponse["login"].toString();
        qDebug()<<"loggin in user: " + login;
        m_sql_contact_model->loginUser(login);
        //contactModel.userLoggedIn(login);
    }
    else if (method == "logout_user"){
        auto login = jsonResponse["login"].toString();
        qDebug()<<"logout user: " + login;
        m_sql_contact_model->logoutUser(login);
        //contactModel.userLogout(login);
    }
}
