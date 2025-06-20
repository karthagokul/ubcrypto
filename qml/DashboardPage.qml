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
        coinModel = DB.getAllCoins() // Ensure this reads flattened fields now
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
                        currentPrice: modelData.current_price
                        price_change_percentage_1h: modelData.price_change_percentage_1h !== null ? modelData.price_change_percentage_1h : 0
                        price_change_percentage_24h: modelData.price_change_percentage_24h !== null ? modelData.price_change_percentage_24h : 0
                        price_change_percentage_7d: modelData.price_change_percentage_7d !== null ? modelData.price_change_percentage_7d : 0
                        price_change_percentage_30d: modelData.price_change_percentage_30d !== null ? modelData.price_change_percentage_30d : 0
                        marketCapRank: modelData.market_cap_rank
                        totalVolume: modelData.total_volume
                        coinImage: modelData.image_url
                }
            }
        }
    }
}
