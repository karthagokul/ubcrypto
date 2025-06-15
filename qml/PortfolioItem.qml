// qml/components/PortfolioItem.qml
import QtQuick 2.7
import Lomiri.Components 1.3

Item {
    id: portfolioItem
    width: parent.width
    height: units.gu(8)

    property string coinName
    property string coinSymbol
    property real quantity
    property string currentPrice

    Rectangle {
        anchors.fill: parent
        color: "#fafafa"
        border.color: "#ccc"
        radius: 8
        anchors.margins: units.gu(0.5)

        Row {
            anchors.centerIn: parent
            spacing: units.gu(2)

            Column {
                Text {
                    text: coinName
                    font.bold: true
                }
                Text {
                    text: coinSymbol
                }
            }

            Column {
                Text {
                    text: "Qty: " + quantity
                }
                Text {
                    text: "Now: " + currentPrice
                }
            }
        }
    }
}
