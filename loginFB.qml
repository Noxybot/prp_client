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
             console.log("URL: " + loadRequest.url + ", status: " + loadRequest.status + ", " + loadRequest.errorString)
             let pos = loadRequest.url.toString().lastIndexOf("#access_token=");
             if (pos !== -1){
                 let access_token = loadRequest.url.toString().substring(pos + 14,
                                                              loadRequest.url.toString().lastIndexOf("&data_access_expiration_time"))
                 if (access_token.length !== 0)
                 {
                     console.log("TOKEN:" + access_token)
                     img.source = "https://graph.facebook.com/me/picture?access_token=" + access_token
                     console.log("WEBURL CURRENT: " + "https://graph.facebook.com/me/picture?access_token=" + access_token)
                 }
             }


         }

//anchors.fill: parent
    url: "https://www.facebook.com/dialog/oauth?client_id=261012394932672&redirect_uri=https://www.facebook.com/connect/login_success.html&response_type=token&scope=email"


}
