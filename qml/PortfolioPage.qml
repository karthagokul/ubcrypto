import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Controls 2.2
import QtQuick.Window 2.2
import "datastore.js" as DB

Page {
    id: portfolioPage

    header: PageHeader {
        title: "Portfolio"
    }

    Flickable {
        id: flick
        anchors.fill: parent
        contentHeight: contentColumn.implicitHeight
        clip: true

        Column {
            id: contentColumn
            width: parent.width
            spacing: units.gu(2)
            anchors.margins: units.gu(2)

            // === Top row with Combo + Buttons ===
            Row {
                id: topRow
                spacing: units.gu(1)
                width: parent.width

                ComboBox {
                    id: portfolioSelector
                    width: parent.width * 0.4
                    model: portfolioNames
                    onCurrentIndexChanged: {
                        selectedPortfolio = portfolioIds[currentIndex];
                        loadHoldingsForPortfolio(selectedPortfolio);
                    }
                }

                Button {
                    text: "New"
                    width: parent.width * 0.18
                    onClicked: newPortfolioDialog.open()
                }

                Button {
                    text: "Coin"
                    width: parent.width * 0.18
                    enabled: selectedPortfolio !== -1
                    onClicked: addCoinDialog.open()
                }

                Button {
                    text: "Delete"
                    width: parent.width * 0.18
                    enabled: selectedPortfolio !== -1
                    onClicked: {
                        DB.deletePortfolio(selectedPortfolio);
                        reloadPortfolios();
                    }
                }
            }

            // === Holdings Header ===
            Text {
                text: "Your Holdings"
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
                        change24h: modelData.change_24h    // optional
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
        holdingsModel = DB.getHoldings(portfolioId);
    }
}
