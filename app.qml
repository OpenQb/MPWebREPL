import Qb 1.0
import Qb.Core 1.0

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.3

QbApp{
    id: appUi
    Keys.forwardTo: [objWebREPL]

    QbSettings {
        id: appSettings
        name: "MPWebREPL"
        property alias ip: objWebREPL.ip
    }

    QbMetaTheme{
        id: appTheme
    }

    Connections{
        target: Qt.inputMethod
        onVisibleChanged:{
            if(Qt.inputMethod.visible){
                if(Qt.platform.os === "android"){
                    var v = false;
                    if(appUi.height>appUi.width){
                        v = true;
                    }
                    if(v){
                        objInvisibleBlock.height = QbCoreOne.scale(275);
                    }
                    else{
                        objInvisibleBlock.height = QbCoreOne.scale(200);
                    }
                }
                else if(Qt.platform.os === "ios"){
                    objInvisibleBlock.height = Qt.inputMethod.keyboardRectangle.height();
                }
            }
            else{
                objInvisibleBlock.height = 1;
            }
        }
    }

    Pane{
        id: appMainPage
        topPadding: QbCoreOne.scale(25)
        bottomPadding: 0
        leftPadding: 0
        rightPadding: 0
        Material.background: appTheme.background
        Material.foreground: appTheme.foreground
        Material.accent: appTheme.accent
        Material.primary: appTheme.primary
        Material.theme: appTheme.theme === "dark"?Material.Dark:Material.Light
        anchors.fill: parent
        WebREPL{
            id: objWebREPL
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: objInvisibleBlock.top
        }
        Item{
            id: objInvisibleBlock
            width: parent.width
            height: 1
            anchors.bottom: parent.bottom
        }
    }
}
