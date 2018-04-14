import Qb 1.0
import Qb.Core 1.0

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.3

QbApp{
    id: appUi
    Keys.forwardTo: []

    QbSettings {
        id: appSettings
        name: "MPWebREPL"
    }

    QbMetaTheme{
        id: appTheme
    }

    Page{
        id: appMainPage
        Material.background: appTheme.background
        Material.foreground: appTheme.foreground
        Material.accent: appTheme.accent
        Material.primary: appTheme.primary
        Material.theme: appTheme.theme === "dark"?Material.Dark:Material.Light
    }
}
