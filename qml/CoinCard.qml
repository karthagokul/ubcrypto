import QtQuick 2.7
import Lomiri.Components 1.3

Rectangle {
    id: coinCard
    width: parent.width
    color: "#ffffff"
    border.color: "#ccc"
    radius: 8
    anchors.margins: units.gu(0.5)

    property string coinName: ""
    property string coinSymbol: ""
    property string price: ""
    property string change24h: ""
    property url coinImage: ""

    implicitHeight: contentRow.implicitHeight + units.gu(2)

    Row {
        id: contentRow
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
            spacing: units.gu(0.3)
            width: parent.width * 0.4

            Text {
                text: coinName
                font.pixelSize: units.gu(2.2)
                font.bold: true
                wrapMode: Text.WordWrap
                color: "#222"
                width: parent.width
            }

            Text {
                text: coinSymbol
                font.pixelSize: units.gu(1.8)
                color: "#666"
            }
        }

        // Spacer to push right column to the end
        Item {
            width: units.gu(2)
            height: 1
        }

        // Price + Change
        Column {
            spacing: units.gu(0.3)
            width: parent.width * 0.3

            Text {
                text: "$" + price
                font.pixelSize: units.gu(2)
                horizontalAlignment: Text.AlignRight
                width: parent.width
            }

            Text {
                text: change24h
                font.pixelSize: units.gu(1.8)
                color: change24h.startsWith("+") ? "green" : "red"
                horizontalAlignment: Text.AlignRight
                width: parent.width
            }
        }
    }
}
