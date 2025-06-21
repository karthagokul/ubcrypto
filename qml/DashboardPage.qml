import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Controls 2.2
import io.thp.pyotherside 1.4
import "datastore.js" as DB
import io.thp.pyotherside 1.4

Page {
    id: dashboardPage

    header: PageHeader {
        title: "Market Overview"
    }

    // === Coin model loaded from SQLite
    property var coinModel: []
    property string currentFilter: "all"

    Component.onCompleted: {
        coinModel = DB.getAllCoins()
    }

    function applyFilter(filter) {
        currentFilter = filter;
        if (filter === "all") {
            coinModel = DB.getAllCoins()
        } else if (filter === "gainers") {
            coinModel = DB.getTopGainers()
        } else if (filter === "losers") {
            coinModel = DB.getTopLosers()
        }
    }

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl("../src/"));
            importModule("cli", function () {

            });
        }

        onError: function (errorName, errorMessage, traceback) {
            console.log("Python Error:", errorName, errorMessage, traceback);
        }
    }

    Flickable {
        anchors.fill: parent
        anchors.margins: units.gu(1)
        contentHeight: coinList.height
        clip: true

        Column {
            id: coinList
            width: parent.width
            spacing: units.gu(1)
            anchors.margins: units.gu(1)

            // === Filter Buttons ===
            Row {
                width: parent.width
                spacing: units.gu(1)
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    text: "All"
                    highlighted: currentFilter === "all"
                    onClicked: applyFilter("all")
                }
                Button {
                    text: "Top Gainers"
                    highlighted: currentFilter === "gainers"
                    onClicked: applyFilter("gainers")
                }
                Button {
                    text: "Top Losers"
                    highlighted: currentFilter === "losers"
                    onClicked: applyFilter("losers")
                }
            }
            // === Empty State: Show refresh if no coins ===
            Item {
                width: parent.width
                height: coinModel.length === 0 ? units.gu(20) : 0
                visible: coinModel.length === 0

                Column {
                    anchors.centerIn: parent
                    spacing: units.gu(1)
                    width: parent.width

                    Label {
                        text: "No data available."
                        font.pixelSize: units.gu(2.2)
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Button {
                        text: "Refresh"
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            console.log("Calling the Python Sync")
                            python.call("cli.start_background_sync",  function (result) {
                                console.log("Started")
                            });
                            applyFilter(currentFilter)
                        }
                    }
                }
            }


            // === Coin Cards ===
            Repeater {
                model: coinModel

                delegate: CoinCard {
                    coinName: modelData.name
                    coinSymbol: modelData.symbol
                    currentPrice: modelData.current_price
                    price_change_percentage_1h: modelData.price_change_percentage_1h || 0
                    price_change_percentage_24h: modelData.price_change_percentage_24h || 0
                    price_change_percentage_7d: modelData.price_change_percentage_7d || 0
                    price_change_percentage_30d: modelData.price_change_percentage_30d || 0
                    marketCapRank: modelData.market_cap_rank
                    totalVolume: modelData.total_volume
                    coinImage: modelData.image_url
                }
            }
        }
    }
}
