import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12
import QtPositioning 5.14
import QtLocation 5.14
import QtQuick.Layouts 1.12
import QtQml 2.14


Page {
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
                text: qsTr("\u2630")
                width: parent.width * 0.7
                height: parent.height * 0.7
                font.pointSize: 100
                minimumPointSize: 10
                fontSizeMode: Text.Fit
                anchors.centerIn: parent
            }

        }
        TextField {
            anchors.right:  parent.right
            placeholderText: qsTr("Искать место...")
            anchors.rightMargin: parent.width*0.015
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width/2
            background: Rectangle {
                radius: 5
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
                text: qsTr("Профиль")
                width: parent.width
                onClicked: {
                    drawer.close()
                    if(stack.top !== "profile.qml")
                        stack.push("profile.qml")
                }
            }
            ItemDelegate {
                text: qsTr("Чаты")
                width: parent.width
                onClicked: {
                    drawer.close()
                    stack.push("contacts.qml")
                }
            }
            ItemDelegate {
                text: qsTr("Выйти")
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
                anchorPoint.x: image.width / 4
                anchorPoint.y: image.height
                coordinate: position
                enabled: true
                MouseArea {
                    id:nested
                    // preventStealing: true;
                    anchors.fill: parent;
                    onClicked:
                    {
                        bottomProfile.visible = true;
                        name_.text = name;
                        info.text = from_time + " - " + to_time + '\t' + expected_expenses + '\t' + expected_people_number
                        description_.text = description
                        bottomProfile.receipient = creator_login
                        bottomProfile.placeId = marker_id
                    }
                }

                sourceItem: Image {
                    id: image
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
        property string receipient
        property int placeId
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
                source: "images/worldwide-location.png"
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
                    text: bottomProfile.receipient === currentUserLogin ? "Удалить" : "Ответить"
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
                            let receipent = bottomProfile.receipient
                            conversationModel.setRecipient(receipent)
                            stack.push("chat.qml", {"inConversationWith" : bottomProfile.receipient,
                                       "imageBase64": contactModel.getUserImageByLogin(receipent)})
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
            }
        }
    }
}
