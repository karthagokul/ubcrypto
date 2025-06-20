import QtQuick 2.7
import Lomiri.Components 1.3

Rectangle {
    id: portfolioCard
    width: parent ? parent.width : Screen.width
    height: units.gu(10)
    radius: 8
    color: "#fff"
    border.color: "#ddd"
    anchors.margins: units.gu(0.5)

    // Input Properties
    property string coinName: ""
    property string coinSymbol: ""
    property string price: ""
    property string total_value: ""
    property url coinImage: ""
    property real quantity: 0

    Row {
        anchors.fill: parent
        anchors.margins: units.gu(1)
        spacing: units.gu(2)

        // === Left Section: Icon + Name + Symbol ===
        Item {
            width: parent.width * 0.5
            height: parent.height

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: units.gu(1)

                Image {
                    source: coinImage
                    width: units.gu(4)
                    height: units.gu(4)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    visible: coinImage !== ""
                }

                Column {
                    spacing: units.gu(0.3)
                    width: parent.width * 0.35

                    Text {
                        text: coinName
                        font.pixelSize: units.gu(2.2)
                        font.bold: true
                        color: "#222"
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        text: coinSymbol.toUpperCase()
                        font.pixelSize: units.gu(1.8)
                        color: "#666"
                    }
                }
            }
        }

        // === Right Section: Qty, Price, Total ===
        Item {
            width: parent.width * 0.45
            height: parent.height

            Column {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: units.gu(0.3)

                Text {
                    text: "Qty: " + quantity
                    font.pixelSize: units.gu(1.5)
                    color: "#444"
                    horizontalAlignment: Text.AlignRight
                }

                Text {
                    text: "Unit: $" + Number(price).toFixed(2)
                    font.pixelSize: units.gu(1.5)
                    color: "#333"
                    horizontalAlignment: Text.AlignRight
                }

                Text {
                    text: "Total: $" + Number(total_value).toFixed(2)
                    font.pixelSize: units.gu(1.5)
                    color: "#333"
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }
}
