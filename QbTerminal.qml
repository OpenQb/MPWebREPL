import QtQuick 2.10

Item{
    property color textColor: "white"
    property color bgColor: "black"
    property color verticalScrollBarColor: "white"
    property color cursorColor: "white"
    property int cursorWidth: 5
    property int leftMargin: 10
    property int rightMargin: 10
    property int topMargin: 10
    property int bottomMargin: 10
    property int bottomExtraSpace: 100
    property string fontFamily: "vrinda"
    property int fontSize: 15
    property int verticalScrollBarHeight: 18

    property bool terminalEnabled: true

    signal command(string cmd);
    signal upArrowPressed();
    signal downArrowPressed();

    id: objQbTerminal
    width: 500
    height: 500
    clip: true
    enabled: true
    Keys.forwardTo: [objTerminalInput]

    onActiveFocusChanged: {
        if(activeFocus){
            properFocus();
        }
    }

    function setCursorToEnd(){
        objTerminalContents.cursorPosition = objTerminalContents.length;
    }

    function passwordMode(){
        objTerminalInput.isPasswordMode = true;
    }

    function textMode(){
        objTerminalInput.isPasswordMode = false;
    }

    function isPasswordMode(){
        return objTerminalInput.isPasswordMode;
    }

    function setCommand(cmd){
        if(!objTerminalInput.isPasswordMode){
            objTerminalInputText.text = cmd;
        }
    }

    function properFocus(){
        if(!objTerminalInput.isPasswordMode){
            objTerminalInputText.cursorVisible = true;
            objTerminalInputText.focus = true;
            objTerminalInputText.forceActiveFocus();
        }
        else{
            objTerminalInputPassword.cursorVisible = true;
            objTerminalInputPassword.focus = true;
            objTerminalInputPassword.forceActiveFocus();
        }

        if(objQbTerminalFlickArea.contentHeight>objQbTerminalFlickArea.height){
            objQbTerminalFlickArea.contentY = objQbTerminalFlickArea.contentHeight - objQbTerminalFlickArea.height;
        }

        objTerminalInput.y = objQbTerminalFlickArea.actualContentHeight - objTerminalInput.height;
        //console.log("Content Height:"+objQbTerminalFlickArea.contentHeight);
        //console.log("Terminal:"+objTerminalContents.height);
    }



    function enableTerminal(){
        objQbTerminal.terminalEnabled = true;
    }

    function disableTerminal(){
        objQbTerminal.terminalEnabled = false;
    }

    function refreshInputMethod(){
        if(Qt.inputMethod.visible){
            Qt.inputMethod.hide();
            Qt.inputMethod.show();
        }
    }

    function insertText(text){
        objTerminalContents.insert(objTerminalContents.length,text);
        objTerminalContents.cursorPosition = objTerminalContents.length;
        properFocus();
    }

    function clearTerminal(){
        objTerminalContents.text = "";
        objTerminalInputText.text = "";
        objTerminalInputText.cursorVisible = false;
        objTerminalContents.cursorVisible = false;
        objTerminalInput.y = objQbTerminalFlickArea.actualContentHeight - objTerminalInput.height;
    }


    Rectangle{
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left

        anchors.leftMargin: objQbTerminal.leftMargin
        anchors.rightMargin: objQbTerminal.rightMargin
        anchors.topMargin: objQbTerminal.topMargin
        anchors.bottomMargin: objQbTerminal.bottomMargin
        color: objQbTerminal.bgColor

        MouseArea{
            preventStealing: true
            anchors.fill: parent
            onPressed: {
                if(objQbTerminal.terminalEnabled){
                    properFocus();
                    Qt.inputMethod.show();
                }
                mouse.accepted = true;
            }
            onPositionChanged: {
                mouse.accepted = true;
            }
            onPressAndHold: {
                mouse.accepted = true;
            }
            onClicked: mouse.accepted = true;
            onReleased: mouse.accepted = true;
            onDoubleClicked: mouse.accepted = true;
        }

        Item {
            id: objVerticalScrollBar
            implicitWidth: objQbTerminal.verticalScrollBarHeight
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right

            Connections {
                target: objQbTerminalFlickArea.visibleArea
                onHeightRatioChanged:{
                    objVerticalScrollBar.visible = (objQbTerminalFlickArea.visibleArea.heightRatio < 1);
                }
            }

            Rectangle {
                id: objHandler
                y: objQbTerminalFlickArea.visibleArea.yPosition * objQbTerminalFlickArea.height
                anchors.left: parent.left
                anchors.right: parent.right
                height: objQbTerminalFlickArea.visibleArea.heightRatio * objQbTerminalFlickArea.height
                color: objQbTerminal.verticalScrollBarColor
            }

            MouseArea {
                anchors.fill: parent
                preventStealing: true

                onMouseYChanged:
                    if (mouseY - objHandler.height / 2 <= 0) {
                        objQbTerminalFlickArea.contentY = 0;
                    }
                    else if ((mouseY - objHandler.height / 2) * objQbTerminalFlickArea.contentHeight / objVerticalScrollBar.height >=
                             objQbTerminalFlickArea.contentHeight - objVerticalScrollBar.height) {
                        objQbTerminalFlickArea.contentY = objQbTerminalFlickArea.contentHeight - objVerticalScrollBar.height;
                    }
                    else{
                        objQbTerminalFlickArea.contentY = (mouseY - objHandler.height / 2) * objQbTerminalFlickArea.contentHeight / objVerticalScrollBar.height
                    }
            }
        }

        Flickable {
            property int actualContentHeight:1
            id: objQbTerminalFlickArea
            clip: true
            interactive: false

            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: (objVerticalScrollBar.visible) ? objVerticalScrollBar.left : parent.right
            anchors.left: parent.left
            onActualContentHeightChanged: {
                objQbTerminalFlickArea.contentHeight = objQbTerminalFlickArea.actualContentHeight+objTerminalInput.height+objQbTerminal.bottomExtraSpace;
            }

            Item{
                property bool isPasswordMode: false

                id: objTerminalInput
                anchors.left: parent.left
                anchors.leftMargin: objTerminalInputX.contentWidth-objTerminalInputX.cursorRectangle.width
                height: isPasswordMode?objTerminalInputPassword.height:objTerminalInputText.height
                anchors.right: parent.right

                TextInput{
                    clip: true
                    id: objTerminalInputPassword
                    focus: true
                    enabled: objQbTerminal.terminalEnabled
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    color: textColor
                    text: ""
                    wrapMode: TextEdit.Wrap
                    echoMode: TextInput.Password
                    font.family: objQbTerminal.fontFamily
                    font.pixelSize: objQbTerminal.fontSize
                    activeFocusOnPress: false
                    verticalAlignment: TextEdit.AlignTop
                    height: objTerminalContents.cursorRectangle.height*objTerminalInputPassword.lineCount
                    readOnly: !objQbTerminal.terminalEnabled
                    visible: objQbTerminal.terminalEnabled && objTerminalInput.isPasswordMode
                    cursorDelegate: Rectangle{
                        width: objQbTerminal.cursorWidth
                        color: objQbTerminal.cursorColor
                    }
                    onContentHeightChanged: {
                        objQbTerminalFlickArea.contentHeight = objQbTerminalFlickArea.actualContentHeight+objTerminalInput.height+objQbTerminal.bottomExtraSpace;
                        if(objQbTerminalFlickArea.contentHeight>objQbTerminalFlickArea.height){
                            objQbTerminalFlickArea.contentY = objQbTerminalFlickArea.contentHeight - objQbTerminalFlickArea.height;
                        }
                    }
                    onAccepted: {
                        objQbTerminal.command(objTerminalInputPassword.text);
                        objTerminalInputPassword.text = "";
                    }
                }

                TextEdit{
                    visible: false
                    id: objTerminalInputX
                    text: ">>>|"
                    wrapMode: TextEdit.Wrap
                    inputMethodHints: Qt.ImhNoPredictiveText
                    textFormat: TextEdit.PlainText
                    font.family: objQbTerminal.fontFamily
                    font.pixelSize: objQbTerminal.fontSize
                    activeFocusOnPress: false
                    verticalAlignment: TextEdit.AlignTop
                    height: objTerminalContents.cursorRectangle.height
                    readOnly: false
                }

                TextEdit{
                    clip: true
                    property string oldText: ""
                    id: objTerminalInputText
                    focus: true
                    enabled: objQbTerminal.terminalEnabled
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    color: textColor
                    text: ""
                    wrapMode: TextEdit.Wrap
                    inputMethodHints: Qt.ImhNoPredictiveText|Qt.ImhPreferLowercase
                    textFormat: TextEdit.PlainText
                    font.family: objQbTerminal.fontFamily
                    font.pixelSize: objQbTerminal.fontSize
                    activeFocusOnPress: false
                    verticalAlignment: TextEdit.AlignTop
                    height: objTerminalContents.cursorRectangle.height*objTerminalInputText.lineCount
                    readOnly: !objQbTerminal.terminalEnabled
                    visible: objQbTerminal.terminalEnabled && !objTerminalInput.isPasswordMode
                    cursorDelegate: Rectangle{
                        width: objQbTerminal.cursorWidth
                        color: objQbTerminal.cursorColor
                    }
                    onContentHeightChanged: {
                        objQbTerminalFlickArea.contentHeight = objQbTerminalFlickArea.actualContentHeight+objTerminalInput.height+objQbTerminal.bottomExtraSpace;
                        if(objQbTerminalFlickArea.contentHeight>objQbTerminalFlickArea.height){
                            objQbTerminalFlickArea.contentY = objQbTerminalFlickArea.contentHeight - objQbTerminalFlickArea.height;
                        }
                    }

                    Keys.onUpPressed: {
                        objQbTerminal.upArrowPressed();
                    }
                    Keys.onDownPressed: {
                        objQbTerminal.downArrowPressed();
                    }

                    onLengthChanged: {
                        if(objTerminalInputText.text!==objTerminalInputText.oldText){
                            objTerminalInputText.oldText = objTerminalInputText.text;
                            if(objTerminalInputText.oldText.length>0){
                                var nline = objTerminalInputText.oldText.substring(objTerminalInputText.oldText.length-1,objTerminalInputText.oldText.length);
                                if(nline === "\n"){
                                    var cmd = objTerminalInputText.oldText.substring(0,objTerminalInputText.oldText.length-1);
                                    objTerminalInputText.oldText = "";
                                    objTerminalInputText.text = "";
                                    //insertText(cmd+"\n>>> ");
                                    objQbTerminal.command(cmd);
                                }
                            }
                        }
                    }

                    MouseArea{
                        preventStealing: true
                        anchors.fill: parent
                        onPressed: {
                            if(objQbTerminal.terminalEnabled){
                                properFocus();
                                Qt.inputMethod.show();
                            }
                            mouse.accepted = true;
                        }
                        onPositionChanged: {
                            mouse.accepted = true;
                        }
                        onPressAndHold: {
                            mouse.accepted = true;
                        }
                        onClicked: mouse.accepted = true;
                        onReleased: mouse.accepted = true;
                        onDoubleClicked: mouse.accepted = true;
                    }

                }
            }

            TextEdit{
                id: objTerminalContents
                anchors.left: parent.left
                anchors.right: parent.right
                color: objQbTerminal.textColor
                wrapMode: TextEdit.Wrap
                inputMethodHints: Qt.ImhNoPredictiveText
                textFormat: TextEdit.PlainText
                font.family: objQbTerminal.fontFamily
                font.pixelSize: objQbTerminal.fontSize
                activeFocusOnPress: false
                readOnly: true
                onContentHeightChanged:{
                    objQbTerminalFlickArea.actualContentHeight = contentHeight;
                }


                MouseArea{
                    preventStealing: true
                    anchors.fill: parent
                    onPressed: {
                        if(objQbTerminal.terminalEnabled){
                            properFocus();
                            Qt.inputMethod.show();
                        }
                        mouse.accepted = true;
                    }
                    onPositionChanged: {
                        mouse.accepted = true;
                    }
                    onPressAndHold: {
                        mouse.accepted = true;
                    }
                    onClicked: mouse.accepted = true;
                    onReleased: mouse.accepted = true;
                    onDoubleClicked: mouse.accepted = true;
                }
            }
        }
    }
}
