import Qb 1.0
import Qb.Core 1.0

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.3

import QtWebSockets 1.1

Page{
    id: objWebREPLPage
    width: 500
    height: 500
    property alias ip: objAddress.text
    property bool isConnected: false
    //property string lastCommand:""
    property var history: []
    property int historyIndex: 0
    property string receivedBuffer:""
    anchors.leftMargin: QbCoreOne.scale(10)
    anchors.rightMargin: QbCoreOne.scale(10)
    anchors.topMargin: QbCoreOne.scale(10)
    anchors.bottomMargin: QbCoreOne.scale(10)

    Component.onCompleted: {
        disableMessageSenderBox();
    }

    function enableMessageSenderBox(){
        objMessageSenderBox.echoMode = TextField.Normal
        objMessageSenderBox.enabled = true;
        objMessageSenderBox.text ="";
        //objMessageSenderButton.enabled = true;
        objMessageSenderBox.forceActiveFocus();
    }

    function disableMessageSenderBox(){
        objMessageSenderBox.text = "";
        objMessageSenderBox.enabled = false;
        //objMessageSenderButton.enabled = false;
    }

    function resetSystem(){
        objWebREPLPage.receivedBuffer = "";
    }

    function addMessage(msg){
        objTerminal.insert(objTerminal.length,msg);
        //objTerminal.append(msg)
        //objTerminalFlickArea.flick(0,objTerminal.contentHeight);
    }

    WebSocket{
        id: objWebSocket
        onTextMessageReceived: {
            if(message.indexOf("Password:") === 0){
                addMessage("Welcome to MicroPython.\n");
                addMessage("Enter Password:\n");
                enableMessageSenderBox();
                objMessageSenderBox.echoMode = TextField.Password;
            }
            else if(message.indexOf("Access denied") >= 0){
                addMessage("Access denied.\n");
                objWebSocket.active = false;
                objConnectButton.forceActiveFocus();
                disableMessageSenderBox();
                objWebREPLPage.isConnected = false;
            }
            else if(message.indexOf("WebREPL connected")>=0){
                addMessage("WebREPL connected.\n");
                enableMessageSenderBox();
                objWebREPLPage.isConnected = true;
            }
            else{
                //console.log(message)
                if(message.indexOf(">>>") === 0){
                    addMessage(">>> "+objWebREPLPage.receivedBuffer.slice(0,objWebREPLPage.receivedBuffer.length));
                    objWebREPLPage.receivedBuffer = "";
                    enableMessageSenderBox();
                }
                else if(message.indexOf("...") == 0){
                    addMessage(">>> "+objWebREPLPage.receivedBuffer.slice(0,objWebREPLPage.receivedBuffer.length));
                    objWebREPLPage.receivedBuffer = "";
                    enableMessageSenderBox();
                }
                else{
                    objWebREPLPage.receivedBuffer = objWebREPLPage.receivedBuffer+message
                }
            }
        }
    }

    TextField{
        id: objAddress
        width: parent.width - objConnectButton.width
        anchors.top: parent.top
        text: "ws://192.168.4.1:8266"
    }

    Button{
        id: objConnectButton
        anchors.top: parent.top
        anchors.left: objAddress.right
        width: QbCoreOne.scale(120)
        height: QbCoreOne.scale(40)
        text: objWebSocket.active?"DISCONNECT":"CONNECT"
        Material.background: appTheme.primary
        onClicked: {
            if(objWebSocket.active){
                objWebSocket.active = false;
                resetSystem();
                disableMessageSenderBox();
                objWebREPLPage.isConnected = false;
            }
            else{
                objWebSocket.url = objWebREPLPage.ip;
                objWebSocket.active = true;
            }
        }
    }

    Flickable {
        id: objTerminalFlickArea
        clip: true
        width: parent.width
        height: parent.height - objAddress.height - bottomBar.height
        contentWidth: width
        contentHeight: objTerminal.contentHeight
        anchors.top: objAddress.bottom
        contentY:  objTerminalFlickArea.contentHeight<objTerminalFlickArea.height?0:objTerminalFlickArea.contentHeight - objTerminalFlickArea.height
        TextEdit{
            id: objTerminal
            width: parent.width
            height: parent.height
            color: appTheme.foreground
            wrapMode: TextEdit.Wrap
            inputMethodHints: Qt.ImhNoPredictiveText
            //readOnly: true
            textFormat: TextEdit.PlainText
        }
    }

    Row{
        id: bottomBar
        anchors.top: objTerminalFlickArea.bottom
        width: parent.width
        height: QbCoreOne.scale(50)
        TextField{
            id: objMessageSenderBox
            width: parent.width
            wrapMode: TextEdit.Wrap
            inputMethodHints: Qt.ImhNoPredictiveText
            Keys.onUpPressed: {
                //console.log("Up")
                if(objWebREPLPage.history.length==0) return;
                objMessageSenderBox.text = objWebREPLPage.history[objWebREPLPage.historyIndex];
                if(objWebREPLPage.historyIndex>0){
                    objWebREPLPage.historyIndex = objWebREPLPage.historyIndex - 1;
                }
            }
            Keys.onDownPressed: {
                //console.log("Down")
                if(objWebREPLPage.history.length==0) return;
                //console.log(objWebREPLPage.historyIndex);
                if(objWebREPLPage.historyIndex<objWebREPLPage.history.length-1){
                    objWebREPLPage.historyIndex = objWebREPLPage.historyIndex + 1;
                }
                objMessageSenderBox.text = objWebREPLPage.history[objWebREPLPage.historyIndex];
            }

            Keys.onReturnPressed: {
                var text = objMessageSenderBox.text;
                if(objWebREPLPage.isConnected){
                    if(text === "clear"){
                        objTerminal.clear();
                    }
                    else{
                        if(objWebREPLPage.history.length === 0){
                            objWebREPLPage.history.push(text);
                            objWebREPLPage.historyIndex = objWebREPLPage.history.length-1;
                        }
                        else{
                            var lastOne = objWebREPLPage.history[objWebREPLPage.history.length-1];
                            if(lastOne !== text){
                                objWebREPLPage.history.push(text);
                                objWebREPLPage.historyIndex = objWebREPLPage.history.length-1;
                            }
                        }
                        objWebSocket.sendTextMessage(text+"\r");
                        disableMessageSenderBox();
                    }
                }
                else{
                    objWebSocket.sendTextMessage(text+"\r");
                    disableMessageSenderBox();
                }
                objMessageSenderBox.text = "";
            }
        }
    }
}
