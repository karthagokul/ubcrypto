import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3

Rectangle {
    id: coinCard
    width: parent.width
    anchors.margins: units.gu(0.5)

    property string coinName: ""
    property string coinSymbol: ""
    property real currentPrice: 0
    property real change24h: 0
    property real change7d: 0
    property int marketCapRank: -1
    property real totalVolume: 0
    property url coinImage: ""

    property real price_change_percentage_1h: 0
    property real price_change_percentage_24h: 0
    property real price_change_percentage_7d: 0
    property real price_change_percentage_30d: 0

    implicitHeight: contentRow.implicitHeight + units.gu(2)

    Row {
        id: contentRow
        width: parent.width
        spacing: units.gu(1)
        anchors.margins: units.gu(1)

        // ─── Coin Icon ───
        Rectangle {
            width: units.gu(6)
            height: units.gu(6)
            color: "#f7f7f7"
            radius: 6
            border.color: "#ddd"

            Image {
                anchors.centerIn: parent
                source: coinImage
                width: parent.width * 0.8
                height: parent.height * 0.8
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
        }

        // ─── Coin Info ───
        Row {
            width: parent.width * 0.40
            spacing: units.gu(0.3)

            // Coin name + symbol
            Column {
                spacing: 0

                Text {
                    text: coinName
                    font.pixelSize: units.gu(2.2)
                    font.bold: true
                    color: "#222"
                    wrapMode: Text.WordWrap
                    elide: Text.ElideNone
                    width: parent.width    // Make sure this limits the line length
                }


                Text {
                    text: coinSymbol.toUpperCase() + " #" + marketCapRank
                    font.pixelSize: units.gu(1.6)
                    color: "#666"
                }
            }
        }


        // ─── Price + Change Stats ───
        Column {
            width: parent.width * 0.39
            height:parent.height
            spacing: units.gu(1)
            anchors.verticalCenter: parent.verticalCenter
            Layout.alignment: Qt.AlignRight // Use Layout.alignment for Column/Row/Grid layouts

            PriceWidget { // Use your new component here
                  value: currentPrice // Pass your price data to the 'value' property
                  // currencySymbol: "$" // Optional, "$" is default
                  font.pixelSize: units.gu(2) // You can override font size or other properties here
                  font.bold: true
                  color: "#000"
                  // horizontalAlignment and width are handled internally, but can be overridden if needed
              }
            ChangeStats {
                width: parent.width
                height: parent.height
                change1h: price_change_percentage_1h
                change24h: price_change_percentage_24h
                change7d: price_change_percentage_7d
                change30d: price_change_percentage_30d
            }
        }
    }
}
