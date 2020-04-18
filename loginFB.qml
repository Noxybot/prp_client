import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12
//import QtWebEngine 1.10
import Cometogether.downloader 1.0
import QtWebView 1.1

WebView {
    BackendFileDonwloader {
         id: downloader
         onDownloaded: {
             console.log("Saved image: " + id + " in: " + path)
             addUserImagePath(id, path) //FB user login same as FB id
         }
    }
         anchors.fill: parent
         id: view
         url: "https://www.facebook.com/dialog/oauth?client_id=261012394932672&redirect_uri=https://www.facebook.com/connect/login_success.html&response_type=token&scope=email"

         onLoadingChanged: {
             console.log("UPDATED URL: " + loadRequest.url + ", status: " + loadRequest.status + ", " + loadRequest.errorString)
             let pos = loadRequest.url.toString().lastIndexOf("#access_token=");
             if (pos !== -1){
                 let access_token = loadRequest.url.toString().substring(pos + 14,
                                                              loadRequest.url.toString().lastIndexOf("&data_access_expiration_time"))
                 if (access_token.length !== 0)
                 {
                     console.log("TOKEN:" + access_token)
                     let url = "https://graph.facebook.com/me?fields=name,picture.type(large)&access_token=" + access_token
                     console.log("URL: " + url)
                     let xhr = new XMLHttpRequest;
                     xhr.open("GET", url, true)
                     xhr.send()
                     xhr.onload = function() {
                        console.log(`Загружено: ${xhr.status} ${xhr.response}`);
                        let json = JSON.parse(xhr.response)
                        let display_name = json["name"]
                        let name_surname = display_name.split(' ') //[0] is a name and [1] is a surname
                        if (name_surname.length !== 2) {
                            console.log("name_surname.length !== 2")
                            return
                        }

                        console.log("DN: " + display_name)
                        console.log("ID: " + json["id"])
                        let img_url = json.picture.data.url
                        console.log("IMG url: " + img_url)
                        downloader.downloadFile(img_url, json["id"]);

                        if (addUser(name_surname[0], name_surname[1], json["id"], "", "", true)) { //use facebook ID as user login
                            console.log("adduser(FB) returned true")
                            stack.pop()
                            stack.push("map.qml")
                        }
                        else
                            console.log("FB User was not registered")
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

}
