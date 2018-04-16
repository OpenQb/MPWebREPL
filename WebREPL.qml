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
    //property string lastCommand:""
    property var history: []
    property int historyIndex: 0
    property string receivedBuffer:""
    anchors.leftMargin: QbCoreOne.scale(10)
    anchors.rightMargin: QbCoreOne.scale(10)
    anchors.topMargin: QbCoreOne.scale(10)
    anchors.bottomMargin: QbCoreOne.scale(10)


    function resetSystem(){
        objTerminalFlickArea.clearTerminal();
    }

    WebSocket{
        id: objWebSocket
        onTextMessageReceived: {
            if(message.indexOf("Password:") === 0){
                objTerminalFlickArea.passwordMode();
                objTerminalFlickArea.insertText("Enter Password\n>>> ");
            }
            else if(message.indexOf("Access denied") >= 0){
                objTerminalFlickArea.textMode();
                objTerminalFlickArea.insertText("Access denied.\n>>> ");
                objWebSocket.active = false;
                objConnectButton.forceActiveFocus();
                objWebREPLPage.isConnected = false;
            }
            else if(message.indexOf("WebREPL connected")>=0){
                objTerminalFlickArea.textMode();
                objTerminalFlickArea.insertText("WebREPL connected.\n>>> ");
                objWebREPLPage.isConnected = true;
            }
            else{
                objTerminalFlickArea.textMode();
                objTerminalFlickArea.insertText(message)
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
                objTerminalFlickArea.disableTerminal();
            }
            else{
                objWebSocket.url = objWebREPLPage.ip;
                objWebSocket.active = true;
                objTerminalFlickArea.enableTerminal();
                objTerminalFlickArea.clearTerminal();
                objTerminalFlickArea.insertText("Welcome To Micropython\n");
            }
        }
    }

    QbTerminal {
        id: objTerminalFlickArea
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
            console.log("Up")
        }
        onDownArrowPressed: {
            console.log("Down")
        }

        onCommand: {
            if(cmd.length>0){
                if(cmd.indexOf("::") === 0 && !objTerminalFlickArea.isPasswordMode()){
                    if(cmd === "::clear"){
                        objTerminalFlickArea.clearTerminal();
                        objTerminalFlickArea.insertText("Welcome To Micropython\n>>> ");
                        objTerminalFlickArea.refreshInputMethod();
                    }
                }
                else{
                    objWebSocket.sendTextMessage(cmd+"\r");
                }
            }
            else{
                objWebSocket.sendTextMessage(cmd+"\r");
            }
        }
    }
}
