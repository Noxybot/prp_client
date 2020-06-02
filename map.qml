import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtPositioning 5.14
import QtLocation 5.14
import QtQuick.Layouts 1.12
import QtQml 2.14


Page {
    property bool enableAddMarker: false
    StackView.onActivated: {
        markerModel.restoreState();
        addButton.visible=true
    }

    function remove (arr, elem){
        let index = arr.indexOf(elem);
        if (index !== -1) arr.splice(index, 1);
    }
    //    WorkerScript {
    //        id: fetcher
    //        source: "imageFetcher.js"

    //        onMessage:{console.log("imageFetcher succeed"); profileImageBase64 = messageObject.image; }
    //    }


    //    StackView.onActivated: {
    //        if (profileImageBase64.length === 0)
    //            fetcher.sendMessage({"login": currentUserLogin, "serverIP": serverIP})
    //    }


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
                text: "Профиль"//"\uf2bd"
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
                text: "Чаты"//"\uf086"
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
                text: "Выйти"//"\uf52b"
                font {
                    family: "Font Awesome 5 Free Solid"
                    bold: true
                }
                width: parent.width
                onClicked: {
                    drawer.close()
                    mainWebsocket.show_popup = false
                    mainWebsocket.active = false
                }
            }
        }
    }
    Popup {
        id: popupMarkerGuide
        property alias popMessage: message.text

        background: Rectangle {
            implicitWidth: mainWindow.width
            implicitHeight: 60
            color: "#b44"
        }
        y: 0
        modal: true
        focus: true
        closePolicy: Popup.CloseOnPressOutside
        Text {
            id: message
            text: qsTr("Нажмите и подержите в месте на карте, чтобы поставить маркер")
            anchors.centerIn: parent
            font.pointSize: 12
            color: "white"
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
                Component.onCompleted: {
                    switch(subcategory){
                    case "Велоспорт": image_.source = "images/markers/sport/1.1.png";
                        break;
                    case "Футбол": image_.source = "images/markers/sport/1.2.png";
                        break;
                    case "Бег": image_.source = "images/markers/sport/1.4.png";
                        break;
                    case "Баскетбол": image_.source = "images/markers/sport/1.3.png";
                        break;
                    case "Спортзал": image_.source = "images/markers/sport/1.5.png";
                        break;
                    case "Галерея": image_.source = "images/markers/culture/2.1.png";
                        break;
                    case "Экскурсия": image_.source = "images/markers/culture/2.2.png";
                        break;
                    case "Театр": image_.source = "images/markers/culture/2.3.png";
                        break;
                    case "Кинотеатр": image_.source = "images/markers/culture/2.4.png";
                        break;
                    case "Бар": image_.source = "images/markers/night/3.1.png";
                        break;
                    case "Ресторан": image_.source = "images/markers/night/3.2.png";
                        break;
                    case "Клуб": image_.source = "images/markers/night/3.3.png";
                        break;
                    case "Кофейня": image_.source = "images/markers/fun/4.1.png";
                        break;
                    case "Прогулка": image_.source = "images/markers/fun/4.2.png";
                        break;
                    case "Концерт": image_.source = "images/markers/fun/4.3.png";
                        break;
                    case "Квест": image_.source = "images/markers/fun/4.4.png";
                        break;
                    case "Зоопарк": image_.source = "images/markers/fun/4.5.png";
                        break;
                    }
                }

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
                        time.text = from_time + " - " + to_time
                        amount.text = expected_expenses + (expected_expenses === "" ? "":' грн.\t')
                                + expected_people_number + (expected_people_number === "" ?"":" чел.")
                        description_.text = description
                        bottomProfile.recipient = creator_login
                        bottomProfile.placeId = marker_id
                        bottomProfile.img_source = "image://marker_image_provider/" + marker_id
                        bottomProfile.visible = true
                        addButton.visible = false
                    }
                }

                sourceItem: Image {
                    sourceSize.width: 30
                    sourceSize.height: 30
                    id: image_
                    source: "images/2.1-1.svg"//"http://maps.gstatic.com/mapfiles/ridefinder-images/mm_20_red.png"

                }

            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: mouse.accepted = false
            propagateComposedEvents: true

            onPressAndHold:  {
                if(enableAddMarker){
                    popupMarkerGuide.close()
                    var coordinate = map.toCoordinate(Qt.point(mouse.x,mouse.y))
                    stack.push("markerDescription.qml", { "coordinates" : coordinate})
                }
                //markerModel.addMarker(coordinate, "","")
            }
        }



    }

    Component.onCompleted: {
        markerModel.markerDeleted.connect(function(id){
            console.log("marker deleted id : " + id)
            if (bottomProfile.placeId === id)
                bottomProfile.visible = false;
        })

    }


    Rectangle {
        id: bottomProfile
        property string recipient
        property int placeId: -1
        property alias img_source: locationImage.source
        visible: false
        width: parent.width
        radius: 10
        property var max: 250
        height: (mapPage.height * 0.25 > max) ? mapPage.height * 0.25 : max
        anchors.bottom: parent.bottom
        border.width: 1
        border.color: "#6fda9c"
        color: "#394454"
        RowLayout {
            id:upper
            Layout.alignment: Qt.AlignTop
            //Layout.alignment: Qt.AlignHCenter
            width: parent.width
            spacing: 8

            Image {

                BusyIndicator {
                    anchors.centerIn: parent
                    running: locationImage.status != Image.Ready
                }
                id: locationImage
                Layout.preferredWidth:  bottomProfile.width*0.3//*4/3
                Layout.preferredHeight: bottomProfile.width*0.3
                Layout.alignment: Qt.AlignLeft
                Layout.topMargin: 10
                Layout.leftMargin: 10
                autoTransform: true
                sourceSize.width: bottomProfile.width*0.3//*4/3
                sourceSize.height: bottomProfile.width*0.3
                onStatusChanged: {
                    if (locationImage === null || locationImage.source === undefined)
                        return
                    if (locationImage.status != Image.Ready){
                        delay(500, function(){
                            let old_src = locationImage.source;
                            locationImage.source = "";
                            locationImage.source = old_src})
                    }}
            }
            ColumnLayout{
                Layout.preferredWidth: bottomProfile.width*0.65
                Layout.preferredHeight: bottomProfile.width*0.3
                Text {
                    id: name_
                    text: qsTr("Название объявления")
                    color: "#6fda9c"
                    font.pointSize: 14
                }
                Text {
                    id: time
                    text: qsTr("Время")
                    color: "white"
                    font.pointSize: 12
                }
                Text {
                    id: amount
                    text: qsTr("Кол-во участников и расходов")
                    color: "white"
                    font.pointSize: 12
                }

            }
            Button {
                transformOrigin: Item.Center
                Layout.alignment:  Qt.AlignTop
                contentItem: Text {
                    text: "\uf00d"
                    font.family: "Font Awesome 5 Free Solid"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 20
                    minimumPointSize: 10
                    fontSizeMode: Text.Fit
                    color: "#f0f0f0"
                }
                Layout.preferredHeight: loginPage.height / 10
                Layout.preferredWidth: loginPage.height / 10
                background: Rectangle {
                    height: parent.height
                    width: height
                    color: "transparent"
                }
                anchors.right: bottomProfile.right;
                anchors.top: bottomProfile.top;
                onClicked: {
                    bottomProfile.placeId = -1;
                    addButton.visible = true
                    bottomProfile.visible = false;
                }
            }
        }
            RowLayout{
                anchors.top: upper.bottom
                anchors.topMargin: 10
                Layout.preferredHeight: bottomProfile.height*0.65
                width: parent.width
                TextArea {
                    id: description_
                    leftPadding: 20
                    rightPadding: 20
                    color: "white"
                    enabled: false
                    clip: true
                    font.pointSize: 12
                    //Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: parent.width*0.6
                    Layout.alignment: Qt.AlignLeft
                    Layout.leftMargin: 10
                    wrapMode: TextEdit.Wrap
                    Layout.preferredHeight: 65
                    background: Rectangle
                    {
                        radius: 20
                        border.color: "#6fda9c"
                        color: "#394454"
                    }

                }
                Button {
                    Layout.alignment: Qt.AlignBottom | Qt.AlignLeft
                    contentItem: Text {
                        text: bottomProfile.recipient === currentUserLogin ? qsTr("Удалить") : qsTr("Ответить")
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 20
                        minimumPointSize: 10
                        fontSizeMode: Text.Fit
                        color: "#f0f0f0"
                    }
                    Layout.maximumWidth: 200
                    Layout.preferredHeight: 50
                    Layout.preferredWidth: parent.width*0.3
                    background: Rectangle {
                        radius: 20
                        color: "#6fda9c"
                    }
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
                                    addButton.visible = true
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
                                               "inConversationWithDN": getDisplayNameByLogin(recipient)})
                            }
                        }
                    }
                }



        }

    }

    RoundButton {
        id: addButton
        contentItem: Text {
            text: " + "
            font.bold: true
            font.pointSize: 24
            color: "white"

        }
        radius: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.right: parent.right
        background: Rectangle{
            color: "#6fda9c"
            radius: parent.width
        }
        onClicked: {
            enableAddMarker = true;
            markerModel.hideALlMarkers();
            popupMarkerGuide.open()
            addButton.visible=false
        }
    }

    footer: ToolBar {
        id: footer
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

                        break;
                    case 1:
                        button1.text = "\uf53f";
                        button1.font.family = "Font Awesome 5 Free Solid"
                        button1.current_category = "Галерея";
                        button1.checked = parent.visible_subcategories.indexOf(button1.current_category) !== -1


                        button2.text = "\uf3ff";
                        button2.font.family = "Font Awesome 5 Free Solid"
                        button2.current_category = "Экскурсия";
                        button2.checked = parent.visible_subcategories.indexOf(button2.current_category) !== -1


                        button3.text = "\uf630";
                        button3.font.family = "Font Awesome 5 Free Solid"
                        button3.current_category = "Театр";
                        button3.checked = parent.visible_subcategories.indexOf(button3.current_category) !== -1

                        button4.text = "\uf008";
                        button4.font.family = "Font Awesome 5 Free Solid"
                        button4.current_category = "Кинотеатр";
                        button4.checked = parent.visible_subcategories.indexOf(button4.current_category) !== -1


                        button5.visible = false;
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

                        button3.text = "\uf57b";
                        button3.font.family = "Font Awesome 5 Free Solid"
                        button3.current_category = "Клуб";
                        button3.checked = parent.visible_subcategories.indexOf(button3.current_category) !== -1

                        button4.visible = false;


                        button5.visible = false;
                        break;
                    case 3:
                        button1.text = "\uf0f4";
                        button1.font.family = "Font Awesome 5 Free Solid"
                        button1.current_category = " Кофейня"
                        button1.checked = parent.visible_subcategories.indexOf(button1.current_category) !== -1

                        button1.text = "\uf554";
                        button1.font.family = "Font Awesome 5 Free Solid"
                        button2.current_category = "Прогулка"
                        button2.checked = parent.visible_subcategories.indexOf(button2.current_category) !== -1

                        button3.text = "\uf001";
                        button3.current_category = "Концерт"
                        button3.font.family = "Font Awesome 5 Free Solid"
                        button3.checked = parent.visible_subcategories.indexOf(button3.current_category) !== -1

                        button4.visible = true;
                        button4.text = "\uf002";
                        button4.current_category = "Квест"
                        button4.checked = parent.visible_subcategories.indexOf(button5.current_category) !== -1

                        button5.visible = true;
                        button5.text = "\uf6ed";
                        button5.current_category = "Зоопарк"
                        button5.font.family = "Font Awesome 5 Free Solid"
                        button5.checked = parent.visible_subcategories.indexOf(button7.current_category) !== -1
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
                anchors.left: type.right
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
                anchors.left: button1.right
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
                anchors.left: button2.right
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
                anchors.left: button3.right
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
                anchors.left: button4.right
            }

        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
