import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtPositioning 5.14
import QtLocation 5.14
import QtQuick.Layouts 1.12
import QtQml 2.14


Page {
    function remove (arr, elem){
        let index = arr.indexOf(elem);
        if (index !== -1) arr.splice(index, 1);
    }
    WorkerScript {
        id: fetcher
        source: "imageFetcher.js"

        onMessage:{console.log("imageFetcher succeed"); profileImageBase64 = messageObject.image; }
    }


    StackView.onActivated: {
        if (profileImageBase64.length === 0)
            fetcher.sendMessage({"login": currentUserLogin, "serverIP": serverIP})
        mainWebsocket.active = true
    }


    id: mapPage
    property string objectName: "mapPage"
    property alias bottomProfile: bottomProfile
    visible: true
    title: qsTr("Come together")
    header: ToolBar {
        ToolButton {
            id: menuButton
            onClicked: {
                drawer.open()
            }

            Text {
                id: menuButtonName
                text: qsTr("\uf0c9")
                width: parent.width * 0.7
                height: parent.height * 0.7
                font.pointSize: 100
                minimumPointSize: 10
                fontSizeMode: Text.Fit
                anchors.centerIn: parent
                font.family: "Font Awesome 5 Free Solid"
                font.bold: true
                color: "#6fda9c"
            }

        }
        TextField {
            id: search
            anchors.right:  delete_.left
            placeholderText: qsTr("Искать место...")
            anchors.rightMargin: parent.width*0.015
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width/2
            leftPadding: 10
            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: "black"
            }
            onTextChanged: {
                console.log(text)
                markerModel.applySearchPhrase(text)
            }
        }
        ToolButton {
            id: delete_
            anchors.right:  parent.right
            text: "\uf00d"
            font.family: "Font Awesome 5 Free Solid"
            font.bold: true
            onClicked: {
                search.clear()
            }
        }
    }

    Drawer {

        id: drawer
        property var max: 300
        width: (parent.width * 0.7 < max) ? parent.width * 0.7 : max
        height: parent.height

        Column {
            anchors.fill: parent

            ItemDelegate {
                text: "\uf2bd"
                font {
                    family: "Font Awesome 5 Free Solid"
                    bold: true
                }
                width: parent.width
                onClicked: {
                    drawer.close()
                    if(stack.top !== "profile.qml")
                        stack.push("profile.qml")
                }
            }
            ItemDelegate {
                text: "\uf086"
                font {
                    family: "Font Awesome 5 Free Solid"
                    bold: true
                }
                width: parent.width
                onClicked: {
                    drawer.close()
                    stack.push("contacts.qml")
                }
            }
            ItemDelegate {
                text: "\uf52b"
                font {
                    family: "Font Awesome 5 Free Solid"
                    bold: true
                }
                width: parent.width
                onClicked: {
                    drawer.close()
                    stack.pop()
                    mainWebsocket.active = false
                }
            }
        }
    }

    Map {
        transformOrigin: Item.Center
        MapParameter {type: "layout";property var layer:"tunnel-oneway-arrows-blue-minor";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"tunnel-oneway-arrows-blue-major";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"tunnel-oneway-arrows-white";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"turning-features-outline";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"road-oneway-arrows-blue-minor";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"road-oneway-arrows-blue-major";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"level-crossings";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"road-oneway-arrows-white";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"bridge-oneway-arrows-blue-minor";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"bridge-oneway-arrows-blue-major";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"bridge-oneway-arrows-white";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"housenum-label";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"waterway-label";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"poi-scalerank4-l15";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"poi-parks_scalerank4";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"poi-scalerank3";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"poi-parks-scalerank3";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"road-label-small";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"road-label-medium";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"road-label-large";property var textField: ["get", "name_ru"]}
        // MapParameter {type: "layout";property var layer:"road-shields-black";property var textField: ["get", "name_ru"]}
        // MapParameter {type: "layout";property var layer:"road-shields-white";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"motorway-junction";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"poi-scalerank2";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"poi-parks-scalerank2";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"rail-label";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"water-label-sm";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"place-residential";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"poi-parks-scalerank1";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"poi-scalerank1";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"airport-label";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"place-islet-archipelago-aboriginal";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"place-neighbourhood";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"place-suburb";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"place-hamlet";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"place-village";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"place-town";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"place-island";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"place-city-sm";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"place-city-md-s";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"place-city-md-n";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"place-city-lg-s";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"place-city-lg-n";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"marine-label-sm-ln";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"marine-label-sm-pt";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"marine-label-md-ln";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"marine-label-md-pt";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"marine-label-lg-ln";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"marine-label-lg-pt";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"state-label-sm";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"state-label-md";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"state-label-lg";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"country-label-sm";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"country-label-md";property var textField: ["get", "name_ru"]}
        MapParameter {type: "layout";property var layer:"country-label-lg";property var textField: ["get", "name_ru"]}

        plugin: Plugin {
            id: myPlugin
            name: "mapboxgl"

            PluginParameter {
                name: "mapboxgl.access_token"
                value: "pk.eyJ1Ijoibm94eWJvdCIsImEiOiJjazdqZmt6YmUwYm83M2Vyd2Y2aWg3Zzd1In0.bKgawEt5mBOd0eGgGNCO5g"
            }

            PluginParameter {
                name: "mapboxgl.mapping.use_fbo"
                value: false
            }
        }
        id: map
        anchors.fill: parent
        center: QtPositioning.coordinate(49.9885475, 36.2329460)
        zoomLevel: 14

        MapItemView {

            anchors.fill: parent
            model: markerModel
            delegate: MapQuickItem {
                id: marker
                anchorPoint.x: image_.width / 4
                anchorPoint.y: image_.height
                coordinate: position
                enabled: true
                MouseArea {
                    id:nested
                    // preventStealing: true;
                    anchors.fill: parent;
                    onClicked:
                    {
                        name_.text = name;
                        info.text = from_time + " - " + to_time + '\t' + expected_expenses + '\t' + expected_people_number
                        description_.text = description
                        bottomProfile.recipient = creator_login
                        bottomProfile.placeId = marker_id
                        bottomProfile.img_source = "data:image/png;base64," + image
                        bottomProfile.visible = true
                    }
                }

                sourceItem: Image {
                    id: image_
                    source: "http://maps.gstatic.com/mapfiles/ridefinder-images/mm_20_red.png"

                }

            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: mouse.accepted = false
            propagateComposedEvents: true

            onPressAndHold:  {
                var coordinate = map.toCoordinate(Qt.point(mouse.x,mouse.y))
                stack.push("markerDescription.qml", { "coordinates" : coordinate})
                //markerModel.addMarker(coordinate, "","")
            }
        }



    }


    Rectangle {
        id: bottomProfile
        property string recipient
        property int placeId: -1
        property alias img_source: locationImage.source
        visible: false
        width: parent.width
        radius: 10
        property var max: 200
        height: (parent.width * 0.4 < max) ? parent.width * 0.4 : max
        anchors.bottom: parent.bottom
        border.width: 1
        border.color: "light gray"
        RowLayout {
            anchors.centerIn: parent
            spacing: 8
            Image {
                id: locationImage
                source: "data:image/png;base64,";//"images/worldwide-location.png"
                Layout.preferredWidth:  bottomProfile.height
                Layout.preferredHeight: bottomProfile.height
            }
            ColumnLayout{
                Layout.preferredWidth: mapPage.width * 0.6
                spacing: 8
                Text {
                    id: name_
                    text: qsTr("Название объявления")
                }
                Text {
                    id: info
                    text: qsTr("Информация")
                }
                Text {
                    id: description_
                    text: qsTr("Краткое\nописание")
                }
                Button {
                    text: bottomProfile.recipient === currentUserLogin ? "Удалить" : "Ответить"
                    onClicked: {
                        if (text == "Удалить")
                        {
                            var xhr = new XMLHttpRequest();
                            xhr.open("POST", "http://" + serverIP, false)
                            xhr.setRequestHeader("Content-type", "application/json")
                            let json_request = {"method": "delete_marker", "user_login": currentUserLogin, "id": bottomProfile.placeId}
                            try {
                                xhr.send(JSON.stringify(json_request));
                                if (xhr.status !== 200) // HTTP OK
                                    console.log("Delete marker error ${xhr.status}: ${xhr.statusText}")
                                else {
                                    bottomProfile.visible = false
                                    console.log("Delete marker success")
                                }
                            } catch(err) {
                                console.log("Delete marker request failed: " + err.prototype.message)
                            }
                        }
                        else {
                            if (stack.top !== "chat.qml") {
                                let recipient = bottomProfile.recipient
                                conversationModel.setRecipient(recipient)
                                stack.push("chat.qml", {"inConversationWith" : recipient,
                                               "imageBase64": contactModel.getUserImageByLogin(recipient),
                                               "inConversationWithDN": getDisplayNameByLogin(recipient)})
                            }
                        }
                    }
                }
            }

        }
        Button {
            text: qsTr("X");
            anchors.right: parent.right;
            anchors.top: parent.top;
            onClicked: {
                parent.visible = false;
                parent.placeId = -1;
            }
        }
    }
    footer: ToolBar {
        RowLayout{
            width: parent.width
            property var visible_subcategories: []
            ComboBox {
                id: type
                model: ["Спорт", "Культурный отдых", "Ночная жизнь", "Развлечения"]
                Layout.preferredWidth: 200
                Layout.alignment: Qt.AlignLeft
                onCurrentIndexChanged:
                {
                    //console.log("onCurrentIndexChanged")
                    switch(type.currentIndex)
                    {
                    case 0:
                        button1.text = "\uf206";
                        button1.font.family = "Font Awesome 5 Free Solid"
                        button1.current_category = "Велоспорт"
                        button1.checked = parent.visible_subcategories.indexOf(button1.current_category) !== -1


                        button2.text = "\uf1e3";
                        button2.font.family = "Font Awesome 5 Free Solid"
                        button2.current_category = "Футбол"
                        button2.checked = parent.visible_subcategories.indexOf(button2.current_category) !== -1


                        button3.text = "\uf70c";
                        button3.font.family = "Font Awesome 5 Free Solid"
                        button3.current_category = "Бег"
                        button3.checked = parent.visible_subcategories.indexOf(button3.current_category) !== -1


                        button4.text = "\uf434";
                        button4.font.family = "Font Awesome 5 Free Solid"
                        button4.current_category = "Баскетбол"
                        button4.checked = parent.visible_subcategories.indexOf(button4.current_category) !== -1


                        button5.visible = true;
                        button5.text = "\uf44b";
                        button5.font.family = "Font Awesome 5 Free Solid"
                        button5.current_category = "Спортзал"
                        button5.checked = parent.visible_subcategories.indexOf(button5.current_category) !== -1


                        button6.visible = false;
                        button7.visible = false;
                        break;
                    case 1:
                        button1.text = "Музей";
                        button1.current_category = "Музей";
                        button1.checked = parent.visible_subcategories.indexOf(button1.current_category) !== -1


                        button2.text = "Галерея";
                        button2.current_category = "Галерея";
                        button2.checked = parent.visible_subcategories.indexOf(button2.current_category) !== -1


                        button3.text = "Экскурсия";
                        button3.current_category = "Экскурсия";
                        button3.checked = parent.visible_subcategories.indexOf(button3.current_category) !== -1

                        button4.text = "Театр";
                        button4.current_category = "Театр";
                        button4.checked = parent.visible_subcategories.indexOf(button4.current_category) !== -1


                        button5.visible = true;
                        button5.text = "\uf008";
                        button5.font.family = "Font Awesome 5 Free Solid"
                        button5.current_category = "Кинотеатр"
                        button5.checked = parent.visible_subcategories.indexOf(button5.current_category) !== -1


                        button6.visible = false;
                        button7.visible = false;
                        break;
                    case 2:
                        button1.text = "\uf0fc";
                        button1.font.family = "Font Awesome 5 Free Solid"
                        button1.current_category = "Бар"
                        button1.checked = parent.visible_subcategories.indexOf(button1.current_category) !== -1


                        button2.text = "\uf2e7";
                        button2.font.family = "Font Awesome 5 Free Solid"
                        button2.current_category = "Ресторан"
                        button2.checked = parent.visible_subcategories.indexOf(button2.current_category) !== -1

                        button3.text = "Клуб";
                        button3.current_category = "Клуб";
                        button3.checked = visible_subcategories.indexOf(button3.current_category) !== -1

                        button4.text = "Кальян";
                        button4.current_category = "Кальян";
                        button4.checked = parent.visible_subcategories.indexOf(button4.current_category) !== -1

                        button5.visible = false;
                        button6.visible = false;
                        button7.visible = false;
                        break;
                    case 3:
                        button1.text = "Цирк";
                        button1.current_category = "Цирк"
                        button1.checked = parent.visible_subcategories.indexOf(button1.current_category) !== -1

                        button2.text = "Парк развлечений";
                        button2.current_category = "Парк развлечений"
                        button2.checked = parent.visible_subcategories.indexOf(button2.current_category) !== -1

                        button3.text = "\uf001";
                        button3.current_category = "Концерт"
                        button3.font.family = "Font Awesome 5 Free Solid"
                        button3.checked = parent.visible_subcategories.indexOf(button3.current_category) !== -1

                        button4.text = "Развлекательный центр";
                        button4.current_category = "Развлекательный центр"
                        button4.checked = parent.visible_subcategories.indexOf(button4.current_category) !== -1

                        button5.visible = true;
                        button5.text = "\uf002";
                        button5.current_category = "Парк развлечений"
                        button5.checked = parent.visible_subcategories.indexOf(button5.current_category) !== -1

                        button6.visible = true;
                        button6.text = "Лазертаг\\Пейнтбол";
                        button6.current_category = "Лазертаг\\Пейнтбол"
                        button6.checked = parent.visible_subcategories.indexOf(button6.current_category) !== -1

                        button7.visible = true;
                        button7.text = "\uf6ed";
                        button7.current_category = "Зоопарк"
                        button7.font.family = "Font Awesome 5 Free Solid"
                        button7.checked = parent.visible_subcategories.indexOf(button7.current_category) !== -1
                        break;
                    }
                }
            }

            ToolButton{
                onCheckedChanged: {
                    if (!checked){
                        markerModel.removeVisibleSubcategory(current_category)
                        remove(parent.visible_subcategories, current_category)
                    }
                    else{
                        markerModel.addVisibleSubcategory(current_category)
                        parent.visible_subcategories.push(current_category)
                    }
                }
                property string current_category: ""
                id: button1
                font.pointSize: 20

                checkable: true
                font.bold: true
                background: Rectangle {
                    radius: 13
                    anchors.fill: parent
                    color: parent.checked ? "#c22d23" : "transparent"
                }
                //anchors.left: type.right
                anchors.verticalCenter: undefined
                Layout.alignment: Qt.AlignLeft
            }
            ToolButton{
                onCheckedChanged: {
                    if (!checked){
                        markerModel.removeVisibleSubcategory(current_category)
                        remove(parent.visible_subcategories, current_category)
                    }
                    else{
                        markerModel.addVisibleSubcategory(current_category)
                        parent.visible_subcategories.push(current_category)
                    }
                }
                property string current_category: ""
                id: button2
                font.pointSize: 20
                anchors.verticalCenter: undefined
                Layout.alignment: Qt.AlignLeft
                checkable: true
                font.bold: true
                background: Rectangle {
                    radius: 13
                    anchors.fill: parent
                    color: parent.checked ? "#c22d23" : "transparent"
                }
               // anchors.left: button1.right
            }
            ToolButton{
                onCheckedChanged: {
                    if (!checked){
                        markerModel.removeVisibleSubcategory(current_category)
                        remove(parent.visible_subcategories, current_category)
                    }
                    else{
                        markerModel.addVisibleSubcategory(current_category)
                        parent.visible_subcategories.push(current_category)
                    }
                }
                property string current_category: ""
                id: button3
                font.pointSize: 20
                font.bold: true
                anchors.verticalCenter: undefined
                Layout.alignment: Qt.AlignLeft
                checkable: true
                background: Rectangle {
                    radius: 13
                    anchors.fill: parent
                    color: parent.checked ? "#c22d23" : "transparent"
                }
               // anchors.left: button2.right
            }
            ToolButton{
                onCheckedChanged: {
                    if (!checked){
                        markerModel.removeVisibleSubcategory(current_category)
                        remove(parent.visible_subcategories, current_category)
                    }
                    else{
                        markerModel.addVisibleSubcategory(current_category)
                        parent.visible_subcategories.push(current_category)
                    }
                }
                property string current_category: ""
                id: button4
                font.pointSize: 20
                font.bold: true
                anchors.verticalCenter: undefined
                Layout.alignment: Qt.AlignLeft
                checkable: true
                background: Rectangle {
                    radius: 13
                    anchors.fill: parent
                    color: parent.checked ? "#c22d23" : "transparent"
                }
               // anchors.left: button3.right
            }
            ToolButton{
                onCheckedChanged: {
                    if (!checked){
                        markerModel.removeVisibleSubcategory(current_category)
                        remove(parent.visible_subcategories, current_category)
                    }
                    else{
                        markerModel.addVisibleSubcategory(current_category)
                        parent.visible_subcategories.push(current_category)
                    }
                }
                property string current_category: ""
                id: button5
                font.pointSize: 20
                font.bold: true
                anchors.verticalCenter: undefined
                Layout.alignment: Qt.AlignLeft
                checkable: true
                background: Rectangle {
                    radius: 13
                    anchors.fill: parent
                    color: parent.checked ? "#c22d23" : "transparent"
                }
                //anchors.left: button4.right
            }
            ToolButton{
                onCheckedChanged: {
                    if (!checked){
                        markerModel.removeVisibleSubcategory(current_category)
                        remove(parent.visible_subcategories, current_category)
                    }
                    else{
                        markerModel.addVisibleSubcategory(current_category)
                        parent.visible_subcategories.push(current_category)
                    }
                }
                property string current_category: ""
                id: button6
                font.pointSize: 20
                font.bold: true
                anchors.verticalCenter: undefined
                Layout.alignment: Qt.AlignLeft
                checkable: true
                background: Rectangle {
                    radius: 13
                    anchors.fill: parent
                    color: parent.checked ? "#c22d23" : "transparent"
                }
               // anchors.left: button5.right
            }
            ToolButton{
                onCheckedChanged: {
                    if (!checked){
                        markerModel.removeVisibleSubcategory(current_category)
                        remove(parent.visible_subcategories, current_category)
                    }
                    else{
                        markerModel.addVisibleSubcategory(current_category)
                        parent.visible_subcategories.push(current_category)
                    }
                }
                property string current_category: ""
                id: button7
                font.pointSize: 20
                font.bold: true
                anchors.verticalCenter: undefined
                Layout.alignment: Qt.AlignLeft
                checkable: true
                background: Rectangle {
                    radius: 13
                    anchors.fill: parent
                    color: parent.checked ? "#c22d23" : "transparent"
                }
               // anchors.left: button6.right
            }
        }
    }
}
