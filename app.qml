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
            anchors.fill: parent
        }
    }
}
