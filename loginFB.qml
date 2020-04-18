import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12
import QtWebEngine 1.10

WebEngineView {
         anchors.fill: parent
         id: view
         onLoadingChanged: {
             console.log("UPDATED URL: " + loadRequest.url + ", status: " + loadRequest.status + ", " + loadRequest.errorString)
             let pos = loadRequest.url.toString().lastIndexOf("#access_token=");
             if (pos !== -1){
                 let access_token = loadRequest.url.toString().substring(pos + 14,
                                                              loadRequest.url.toString().lastIndexOf("&data_access_expiration_time"))
                 if (access_token.length !== 0)
                 {
                     //console.log("URL: " + loadRequest.url + ", status: " + loadRequest.status + ", " + loadRequest.errorString)
                     console.log("TOKEN:" + access_token)
                     //img.source = "https://graph.facebook.com/me/picture?access_token=" + access_token
                     let url = "https://graph.facebook.com/me?access_token=" + access_token
                     console.log("URL: " + url)
                     let xhr = new XMLHttpRequest;
                     xhr.open("GET", url, true)
                     xhr.send()
                     xhr.onload = function() {
                        console.log(`Загружено: ${xhr.status} ${xhr.response}`);
                        let json = JSON.parse(xhr.response)
                        console.log("DN: " + json["name"])
                        console.log("ID: " + json["id"])
                        if (addUser(json["name"], json["id"], "", "", true)) { //use facebook ID as user login
                            console.log("adduser(FB) returned true")
                            stack.push("map.qml")
                        }
                        else
                            console.log("FB User was not registered")
                        let url1 = "https://graph.facebook.com/" + json["id"] + "/picture?type=large&redirect=false"
                        console.log("URL1: " + url1)
                        let xhr1 = new XMLHttpRequest;
                        xhr1.open("GET", url1, true)
                        xhr1.send()

                        xhr1.onload = function() {
                           console.log(`Загружено1: ${xhr1.status} ${xhr1.response}`);
                           let json = JSON.parse(xhr1.response)
                         }
                         xhr1.onerror = function() { // происходит, только когда запрос совсем не получилось выполнить
                           console.log(`Ошибка1 соединения`);
                         };
                         xhr1.onprogress = function(event) { // запускается периодически
                           // event.loaded - количество загруженных байт
                           // event.lengthComputable = равно true, если сервер присылает заголовок Content-Length
                           // event.total - количество байт всего (только если lengthComputable равно true)
                           console.log(`Загружено1 ${event.loaded} из ${event.total}`);
                         };
                     };
                     xhr.onerror = function() { // происходит, только когда запрос совсем не получилось выполнить
                       console.log(`Ошибка соединения`);
                     };
                     xhr.onprogress = function(event) { // запускается периодически
                       // event.loaded - количество загруженных байт
                       // event.lengthComputable = равно true, если сервер присылает заголовок Content-Length
                       // event.total - количество байт всего (только если lengthComputable равно true)
                       console.log(`Загружено ${event.loaded} из ${event.total}`);
                     };
                 }
             }


         }

//anchors.fill: parent
    url: "https://www.facebook.com/dialog/oauth?client_id=261012394932672&redirect_uri=https://www.facebook.com/connect/login_success.html&response_type=token&scope=email"


}
