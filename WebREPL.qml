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
    property int mode: 0
    property var history: []
    property int historyIndex: 0
    property string receivedBuffer:""
    anchors.leftMargin: QbCoreOne.scale(10)
    anchors.rightMargin: QbCoreOne.scale(10)
    anchors.topMargin: QbCoreOne.scale(10)
    anchors.bottomMargin: QbCoreOne.scale(10)


    function resetSystem(){
        objTerminal.clearTerminal();
    }

    WebSocket{
        id: objWebSocket
        onTextMessageReceived: {
            if(message.indexOf("Password:") === 0){
                objTerminal.passwordMode();
                objTerminal.insertText("Enter Password\n>>> ");
            }
            else if(message.indexOf("Access denied") >= 0){
                objTerminal.textMode();
                objTerminal.insertText("Access denied.\n>>> ");
                objWebSocket.active = false;
                objConnectButton.forceActiveFocus();
                objWebREPLPage.isConnected = false;
            }
            else if(message.indexOf("WebREPL connected")>=0){
                objTerminal.textMode();
                objTerminal.insertText("WebREPL connected.\n>>> ");
                objWebREPLPage.isConnected = true;
            }
            else{
                objTerminal.textMode();
                objTerminal.insertText(message)
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
                objWebREPLPage.isConnected = false;
                objTerminal.disableTerminal();
            }
            else{
                objWebSocket.url = objWebREPLPage.ip;
                objWebSocket.active = true;
                objTerminal.enableTerminal();
                objTerminal.clearTerminal();
                objTerminal.insertText("Welcome To MicroPython\n");
            }
        }
    }

    QbTerminal {
        id: objTerminal
        clip: true
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: objAddress.bottom
        anchors.bottom: parent.bottom
        textColor: appTheme.foreground
        bgColor: appTheme.background
        cursorColor: appTheme.accent
        cursorWidth: QbCoreOne.scale(5)
        leftMargin: 0
        rightMargin: 0
        topMargin: 0
        bottomMargin: 0
        bottomExtraSpace: 0
        fontFamily: "vrinda"
        fontSize: 15
        verticalScrollBarHeight: Qt.platform.os === "android"?QbCoreOne.scale(20):QbCoreOne.scale(7)
        verticalScrollBarColor: appTheme.lighter(appTheme.background)

        onUpArrowPressed: {
            if(objWebREPLPage.history.length==0) return;
            if(objWebREPLPage.historyIndex>0){
                objWebREPLPage.historyIndex = objWebREPLPage.historyIndex - 1;
                var cmd  = objWebREPLPage.history[objWebREPLPage.historyIndex];
                objTerminal.setCommand(cmd);
            }
        }
        onWidthChanged: {
            objTerminal.properFocus();
        }
        onHeightChanged: {
            objTerminal.properFocus();
        }

        onDownArrowPressed: {
            if(objWebREPLPage.history.length==0) return;
            if(objWebREPLPage.historyIndex<objWebREPLPage.history.length-1){
                objWebREPLPage.historyIndex = objWebREPLPage.historyIndex + 1;
                var cmd = objWebREPLPage.history[objWebREPLPage.historyIndex];
                objTerminal.setCommand(cmd);
            }
            else{
                objWebREPLPage.historyIndex = objWebREPLPage.history.length;
                objTerminal.setCommand("");
            }
        }

        onCommand: {
            if(cmd.length>0){
                if(cmd.indexOf("::") === 0 && !objTerminal.isPasswordMode()){
                    if(cmd === "::clear"){
                        objTerminal.clearTerminal();
                        objTerminal.insertText("Welcome To MicroPython\n>>> ");
                        objTerminal.refreshInputMethod();
                    }
                }
                else{
                    objWebSocket.sendTextMessage(cmd+"\r");
                }

                if(!objTerminal.isPasswordMode()){
                    if(objWebREPLPage.history.length>0){
                        var lastCmd = objWebREPLPage.history[objWebREPLPage.history.length-1];
                        if(lastCmd !== cmd){
                            objWebREPLPage.history.push(cmd);
                            objWebREPLPage.historyIndex = objWebREPLPage.history.length;
                        }
                    }
                    else{
                        objWebREPLPage.history.push(cmd);
                        objWebREPLPage.historyIndex = 1;
                    }
                }
            }
            else{
                objWebSocket.sendTextMessage(cmd+"\r");
            }
        }
    }
}
