

function fetchImageByLogin(login, callback, serverIP, count) {
    var xhr = new XMLHttpRequest();
    xhr.responseType = "json"
    xhr.open("POST", "http://" + serverIP)
    xhr.setRequestHeader("Content-type", "application/json")

    let json_request = {"method": "get_user_image", "login": login}

    xhr.onload = function(){
        if (xhr.status === 200) {
            if (xhr.response["result"] !== "no image")
                console.log("fetchImageByLogin success")
            callback(login, xhr.response["result"], serverIP, count)
        }
    }
    xhr.onerror = function(){
        console.log("fetchImageByLogin error")
    }

    xhr.send(JSON.stringify(json_request));
}


function callback(login, image, serverIP, count) {
    console.log("imagefetcher: callback called")

    if (count > 6){
        console.log("imagefetcher: 6 attempts made, stopping")
        return;
    }
    if (image === "no image") {
        let timeStart = new Date().getTime();
        while (new Date().getTime() - timeStart < 5000) {
            // Do nothing
        }
        console.log("trying fetch image again")
        fetchImageByLogin(login, callback, serverIP, ++count)
    }
    else {
        console.log("image fetched")
        WorkerScript.sendMessage({ "login": login, "image": image })
    }
}
WorkerScript.onMessage = function(msg) {
    fetchImageByLogin(msg.login, callback, msg.serverIP, 0)
}
