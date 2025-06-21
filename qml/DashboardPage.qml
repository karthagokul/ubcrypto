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
        coinModel = DB.getAllCoins();
       // console.log("Coins loaded:", JSON.stringify(coinModel))
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
        id: mainFlickable // Renamed for clarity
        anchors.fill: parent
        anchors.margins: units.gu(1) // These margins apply to the Flickable itself
        clip: true

        // Create a single content item for the Flickable
        Column {
            id: flickableContent
            width: mainFlickable.width // This column fills the width of the Flickable
            spacing: units.gu(1)

            //  nav bar (no overlap)
            Rectangle {
                property int selectedMenuItem: 0
                id: navBar
                anchors.left: parent.left
                anchors.leftMargin: units.gu(1)
                anchors.rightMargin: units.gu(1)
                anchors.right: parent.right
                height: units.gu(7)
                color: "#f5f5f5"
                border.color: "#ccc"

                Row {
                    anchors.centerIn: parent
                    anchors.left: navBar.left
                    spacing: units.gu(1)

                    Repeater {
                        model: [
                            {
                                name: " All "
                            },
                            {
                                name: " Top Gainers "
                            },
                            {
                                name: " Top Losers "
                            }
                        ]

                        delegate: MouseArea {
                            width: units.gu(10)
                            height: navBar.height
                            onClicked: {
                                navBar.selectedMenuItem = index;
                                if(index===0)
                                {
                                    applyFilter("all")
                                }
                                else if(index===1)
                                {
                                    applyFilter("gainers")
                                }
                                else
                                {
                                    applyFilter("losers")
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"

                                Text {
                                    text: modelData.name
                                    anchors.centerIn: parent
                                    font.pixelSize: units.gu(2)
                                   // font.bold: navBar.selectedMenuItem === index
                                    color: navBar.selectedMenuItem === index ? LomiriColors.orange : "#444"
                                }
                            }
                        }
                    }
                }
            }

            // === Coin Cards (now directly below FilterNavBar within flickableContent) ===
            // This is the Column that holds the Repeater and Empty State
            Column {
                id: coinListContainer // Renamed to avoid confusion with the Repeater's model
                width: parent.width // Fill the width of flickableContent
                spacing: units.gu(1)

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
                                python.call("cli.start_background_sync", function (result) {
                                    console.log("Started background sync. Result:", result)
                                    // IMPORTANT: Refresh the QML model AFTER sync might have completed
                                    // For a real app, you'd want a signal from Python
                                    // when sync is finished, then call applyFilter.
                                    dashboardPage.applyFilter(dashboardPage.currentFilter)
                                });
                            }
                        }
                    }
                }

                Repeater {
                    model: coinModel

                    delegate: CoinCard {
                        // All properties are correctly passed based on the original snippet
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
        // Set the contentHeight of the Flickable to the height of its actual content
        contentHeight: flickableContent.height
    }
}
