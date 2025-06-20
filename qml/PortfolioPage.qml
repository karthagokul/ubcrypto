import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Controls 2.2
import QtQuick.Window 2.2
import "datastore.js" as DB

Page {
    id: portfolioPage

    header: PageHeader {
        title: "Portfolio"
        ActionBar {
            numberOfSlots: 2
            anchors.right: parent.right
            actions: [
                Action {
                    iconName: "add"
                    text: "Portfolio"
                    onTriggered: newPortfolioDialog.open()
                },
                Action {
                    iconName: "delete"
                    text: "Portfolio"
                    onTriggered: {
                        if (selectedPortfolio !== -1) {
                            DB.deletePortfolio(selectedPortfolio)
                            reloadPortfolios()
                        }
                    }
                },
                Action {
                    iconName: "add"
                    text: "Coin"
                    onTriggered: addCoinDialog.open()
                }

            ]
        }
    }

    Flickable {
        id: flick
        anchors.fill: parent
        anchors.margins: units.gu(1)
        contentHeight: contentColumn.implicitHeight
        clip: true

        Column {
            id: contentColumn
            width: parent.width
            spacing: units.gu(2)

            // === Top row with Combo + Buttons ===
            // === Top row with Combo + Total ===
            Row {
                id: topRow
                spacing: units.gu(1)
                width: parent.width

                ComboBox {
                    id: portfolioSelector
                    width: parent.width * 0.4
                    model: portfolioNames
                    onCurrentIndexChanged: {
                        if (currentIndex >= 0 && currentIndex < portfolioIds.length) {
                            selectedPortfolio = portfolioIds[currentIndex];
                            loadHoldingsForPortfolio(selectedPortfolio);
                        } else {
                            selectedPortfolio = -1;
                            holdingsModel = [];
                        }
                    }
                }
                Button {
                    text: "Add"
                    onClicked: {
                        console.log("View Chart clicked")
                    }
                }

                Button {
                    text: "Delete"
                    onClicked: {
                        totalValue = DB.getTodaysTotalValue(selectedPortfolio)
                        console.log("Snapshot refreshed")
                    }
                }
            }

            // === Holdings Header ===
            Text {
                text: "Your Holdings" + " Worth ($" + totalValue.toFixed(2)+")"
                font.bold: true
                font.pointSize: 10
            }

            // === Holdings List ===
            Column {
                id: contentCol
                width: parent.width
                spacing: units.gu(1)

                Repeater {
                    model: holdingsModel
                    delegate: PortfolioItem {
                        coinName: modelData.coin_name      // optional, fallback to symbol if not available
                        coinSymbol: modelData.coin_symbol
                        quantity: modelData.amount
                        price: modelData.current_price     // from DB or pre-fetched
                        total_value: modelData.total_value    // optional
                        coinImage: modelData.image_url     // optional
                    }
                }
            }
        }
    }

    // === Dialog: New Portfolio ===
    NewPortfolioDialog {
        id: newPortfolioDialog
        onPortfolioCreated: {
            console.log("Saving " + name);
            DB.addPortfolio(name);
            reloadPortfolios();
        }
    }

    // === Dialog: Add Coin ===
    AddCoinDialog {
        id: addCoinDialog
        onCoinAdded: {
            if (selectedPortfolio !== -1) {
                DB.addHolding(selectedPortfolio, symbol, amount);
                loadHoldingsForPortfolio(selectedPortfolio);
            }
        }
    }

    // === Properties ===
    property var portfolioNames: []
    property var portfolioIds: []
    property int selectedPortfolio: -1
    property var holdingsModel: []
    property real totalValue: 0.0

    // === Logic ===
    Component.onCompleted: reloadPortfolios()

    function reloadPortfolios() {
        var portfolios = DB.getPortfolios();
        portfolioNames = portfolios.map(p => p.name);
        portfolioIds = portfolios.map(p => p.id);
        if (portfolioIds.length > 0) {
            selectedPortfolio = portfolioIds[0];
            portfolioSelector.currentIndex = 0;
            loadHoldingsForPortfolio(selectedPortfolio);
        } else {
            holdingsModel = [];
        }
    }

    function loadHoldingsForPortfolio(portfolioId) {
        var holdings = DB.getHoldings(portfolioId);
        holdingsModel = holdings;

        // Compute total value from holdings
        var total = 0.0;
        for (var i = 0; i < holdings.length; i++) {
            var val = parseFloat(holdings[i].total_value);
            if (!isNaN(val)) {
                total += val;
            }
        }
        totalValue = total;
    }

}
