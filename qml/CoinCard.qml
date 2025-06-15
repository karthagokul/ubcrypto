// qml/components/CoinCard.qml
import QtQuick 2.7
import Lomiri.Components 1.3

Rectangle {
    id: coinCard
    width: parent.width
    height: units.gu(10)
    color: "white"
    border.color: "#ccc"
    radius: 8
    anchors.margins: units.gu(0.5)

    property string coinName: ""
    property string coinSymbol: ""
    property string price: ""
    property string change24h: ""
    property url coinImage: ""

    Row {
        anchors.fill: parent
        anchors.margins: units.gu(1)
        spacing: units.gu(2)

        // Coin icon
        Image {
            source: coinImage
            width: units.gu(4)
            height: units.gu(4)
            fillMode: Image.PreserveAspectFit
            smooth: true
            visible: coinImage !== ""
        }

        // Name + Symbol
        Column {
            width: parent.width * 0.4
            spacing: units.gu(0.3)

            Text {
                text: coinName
                font.pixelSize: units.gu(2.5)
                font.bold: true
                color: "#222"
                elide: Text.ElideRight
            }

            Text {
                text: coinSymbol
                font.pixelSize: units.gu(2.2)
                color: "#666"
            }
        }

        // Price + Change
        Column {
            width: parent.width * 0.5
            spacing: units.gu(0.3)

            Text {
                text: "$" + price
                font.pixelSize: units.gu(2.4)
                horizontalAlignment: Text.AlignRight
            }

            Text {
                text: change24h
                font.pixelSize: units.gu(2.2)
                color: change24h.startsWith("+") ? "green" : "red"
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
