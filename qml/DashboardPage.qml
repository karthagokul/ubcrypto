import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Controls 2.2
import io.thp.pyotherside 1.4
import "datastore.js" as DB
import QtQuick.Layouts 1.3 // Ensure this is imported if you're using Layouts elsewhere

Page {
    id: dashboardPage

    header: PageHeader {
        title: "Market Overview"
    }

    ListModel {
        id: coinModel
    }
    property string currentFilter: "all"

    Component.onCompleted: {
        var coins = DB.getAllCoins();
        //console.log("Loaded coins:", JSON.stringify(coins));
        loadCoins(coins);
    }

    function loadCoins(dataArray) {
        coinModel.clear();

        for (var i = 0; i < dataArray.length; i++) {
            var item = dataArray[i];

            // Append only QML-safe properties
            coinModel.append({
                name: item.name || "Unknown",
                symbol: item.symbol || "",
                current_price: item.current_price || 0,
                price_change_percentage_1h: item.price_change_percentage_1h || 0,
                price_change_percentage_24h: item.price_change_percentage_24h || 0,
                price_change_percentage_7d: item.price_change_percentage_7d || 0,
                price_change_percentage_30d: item.price_change_percentage_30d || 0,
                market_cap_rank: item.market_cap_rank || -1,
                total_volume: item.total_volume || 0,
                image_url: item.image_url || ""
            });
        }
    }

    function applyFilter(filter) {
        currentFilter = filter;
        var result = [];

        if (filter === "all") {
            result = DB.getAllCoins();
        } else if (filter === "gainers") {
            result = DB.getTopGainers();
        } else if (filter === "losers") {
            result = DB.getTopLosers();
        }

        loadCoins(result);
    }

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl("../src/"));
            importModule("cli", function () {});
        }

        onError: function (errorName, errorMessage, traceback) {
            console.log("Python Error:", errorName, errorMessage, traceback);
        }
    }

    // === Main Layout Column ===
    Column {
        anchors.fill: parent
        spacing: units.gu(1)
        anchors.margins: units.gu(1) // Padding around the content of the Page

        // ─── Filter NavBar ───
        Rectangle {
            id: navBar
            height: units.gu(7)
            width: parent.width
            color: "#1c1c1e"
            border.color: "#333"
            radius: 6

            property int selectedMenuItem: 0

            Row { // This Row lays out filter buttons horizontally
                anchors.centerIn: parent
                spacing: units.gu(1)

                Repeater {
                    model: [
                        { name: " All " },
                        { name: " Top Gainers " },
                        { name: " Top Losers " }
                    ]
                    delegate: MouseArea {
                        width: units.gu(12)
                        height: navBar.height
                        onClicked: {
                            navBar.selectedMenuItem = index;
                            if (index === 0) {
                                applyFilter("all");
                            } else if (index === 1) {
                                applyFilter("gainers");
                            } else {
                                applyFilter("losers");
                            }
                        }
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            Text {
                                text: modelData.name
                                anchors.centerIn: parent
                                font.pixelSize: units.gu(2)
                                color: navBar.selectedMenuItem === index ? LomiriColors.orange : "#f0f0f0"
                            }
                        }
                    }
                }
            }
        }

        // ─── List of Coins ───
        LomiriListView {
            id: coinListView
            // Removed direct anchors.left/right/top/bottom here.
            // The Column parent (main layout) will manage its vertical position and width.
            width: parent.width // This makes it fill the horizontal space of the Column.
            height: parent.height - navBar.height - spacing * 2 // Calculate remaining height.
                                                                // Or use Layout.fillHeight if main Column is a ColumnLayout.
                                                                // If main Column is just a Column, `height: parent.height - navBar.height - ...` is correct.

            // The visibility is now handled by the parent Column, but this item still has its own visible state.
            visible: coinModel.count > 0 // This should be correct. It will show if count > 0.
                                         // If it was still hidden, there's another subtle issue or a race condition.

            // The Column parent (main layout) will position it below navBar based on its order.
            // Top/bottom anchors conflict with Column's vertical positioning.
            spacing: units.gu(1) // Spacing between delegates
            clip: true

            model: coinModel

            delegate: CoinCard {
                width: parent.width // CoinCard takes full width of the ListView
                // No explicit height on delegate here, CoinCard manages its own implicitHeight
                // height: units.gu(10) // If CoinCard calculates its own height, avoid fixing it here.
                                      // If CoinCard's implicitHeight isn't honored by ListView without it,
                                      // then uncommenting this is a temporary workaround.
                coinName: model.name || "N/A"
                coinSymbol: model.symbol || ""
                currentPrice: model.current_price !== undefined ? model.current_price : 0
                price_change_percentage_1h: model.price_change_percentage_1h !== undefined ? model.price_change_percentage_1h : 0
                price_change_percentage_24h: model.price_change_percentage_24h !== undefined ? model.price_change_percentage_24h : 0
                price_change_percentage_7d: model.price_change_percentage_7d !== undefined ? model.price_change_percentage_7d : 0
                price_change_percentage_30d: model.price_change_percentage_30d !== undefined ? model.price_change_percentage_30d : 0
                marketCapRank: model.market_cap_rank !== undefined ? model.market_cap_rank : -1
                totalVolume: model.total_volume !== undefined ? model.total_volume : 0
                coinImage: model.image_url || ""
            }
        }

        // ─── Empty State ───
        Item {
            id: emptyState
            // The column will naturally place this after coinListView if coinListView is visible.
            // If coinListView is visible, this will collapse.
            // If coinListView is NOT visible (because coinModel.count is 0), then this becomes visible.
            // The height of emptyState needs to be defined if coinListView is not visible.
            width: parent.width
            height: parent.height - navBar.height - spacing * 2 // Occupy the same vertical space as coinListView
                                                                // or ensure it has a large enough height
            visible: (coinModel.count === 0) // Correct condition

            // Removed conflicting anchors! The parent Column manages vertical positioning.
            // anchors.left: coinListView.left (No, parent Column handles horizontal for its children)
            // anchors.right: coinListView.right (No)
            // anchors.topMargin: units.gu(1) (No)
            // anchors.top: coinListView.top (No, conflicts with Column positioner)
            // anchors.bottom: coinListView.bottom (No)

            Column {
                anchors.centerIn: parent // Center content within the emptyState Item
                spacing: units.gu(1)
                width: parent.width // Make Column take full width of emptyState

                Label {
                    text: "No data available."
                    font.pixelSize: units.gu(2.2)
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width // Make Label fill its parent Column horizontally
                }

                Button {
                    text: "Refresh"
                    anchors.horizontalCenter: parent.horizontalCenter // Keep centering for the Button
                    onClicked: {
                        console.log("Calling the Python Sync")
                        python.call("cli.start_background_sync", function (result) {
                            console.log("Started background sync. Result:", result)
                            dashboardPage.applyFilter(dashboardPage.currentFilter)
                        });
                    }
                }
            }
            MouseArea { // This MouseArea is good for making the whole empty state clickable for visual feedback
                anchors.fill: parent
            }
        }
    }
}
