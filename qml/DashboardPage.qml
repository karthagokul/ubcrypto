import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Controls 2.2
import io.thp.pyotherside 1.4
import "datastore.js" as DB

Page {
    id: dashboardPage

    header: PageHeader {
        title: "Market Overview"
    }

    // === Coin model loaded from SQLite
    property var coinModel: []

    Component.onCompleted: {
        coinModel = DB.getAllCoins()
    }

    Flickable {
        anchors.fill: parent
        contentHeight: coinList.height
        clip: true

        Column {
            id: coinList
            width: parent.width
            spacing: units.gu(1)
            anchors.margins: units.gu(1)

            Repeater {
                model: coinModel

                delegate: CoinCard {
                    coinName: modelData.name
                    coinSymbol: modelData.symbol
                    price: modelData.price.toFixed(2)
                    change24h: modelData.change24h !== null
                               ? (modelData.change24h >= 0 ? "+" : "") + modelData.change24h.toFixed(2) + "%"
                               : "N/A"
                    coinImage: modelData.image
                }
            }
        }
    }
}
