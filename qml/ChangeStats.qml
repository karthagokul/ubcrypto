import QtQuick 2.7
import QtQuick.Controls 2.2

Item {
    id: changeBox
    property real change1h: 0
    property real change24h: 0
    property real change7d: 0
    property real change30d: 0

    width: parent ? parent.width : 300
    height: implicitHeight

    Grid {
        id: statGrid
        columns: 2
        spacing: units.gu(1)
        anchors.fill: parent
        anchors.margins: units.gu(1)

        // 1h
        Text {
            text: "1h: " + (change1h >= 0 ? "+" : "") + change1h.toFixed(2) + "%"
            color: change1h >= 0 ? "green" : "red"
            font.pixelSize: units.gu(1.4)
        }

        // 24h
        Text {
            text: "24h: " + (change24h >= 0 ? "+" : "") + change24h.toFixed(2) + "%"
            color: change24h >= 0 ? "green" : "red"
            font.pixelSize: units.gu(1.4)
        }

        // 7d
        Text {
            text: "7d: " + (change7d >= 0 ? "+" : "") + change7d.toFixed(2) + "%"
            color: change7d >= 0 ? "green" : "red"
            font.pixelSize: units.gu(1.4)
        }

        // 30d
        Text {
            text: "30d: " + (change30d >= 0 ? "+" : "") + change30d.toFixed(2) + "%"
            color: change30d >= 0 ? "green" : "red"
            font.pixelSize: units.gu(1.4)
        }
    }
}
