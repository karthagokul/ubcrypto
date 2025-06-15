// qml/components/PortfolioCard.qml
import QtQuick 2.7
import Lomiri.Components 1.3
import "./"

CoinCard {
    id: portfolioCard

    // Add quantity property
    property real quantity: 0

    // Add extra row for quantity
    Column {
        anchors.right: parent.right
        anchors.rightMargin: units.gu(2)
        anchors.verticalCenter: parent.verticalCenter
        spacing: units.gu(0.5)

        Text {
            text: "Qty: " + quantity
            font.pixelSize: units.gu(2.2)
            horizontalAlignment: Text.AlignRight
            color: "#333"
        }
    }
}
