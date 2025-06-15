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

            // === Portfolio selector ===
            ComboBox {
                id: portfolioSelector
                model: portfolioNames
                onCurrentIndexChanged: {
                    selectedPortfolio = portfolioIds[currentIndex]
                    loadHoldingsForPortfolio(selectedPortfolio)
                }
            }

            // === Action buttons ===
            Row {
                spacing: units.gu(2)

                Button {
                    text: "➕ New Portfolio"
                    onClicked: newPortfolioDialog.open()
                }

                Button {
                    text: "➕ Add Coin"
                    enabled: selectedPortfolio !== -1
                    onClicked: addCoinDialog.open()
                }

                Button {
                    text: "🗑 Delete Portfolio"
                    enabled: selectedPortfolio !== -1
                    onClicked: {
                        DB.deletePortfolio(selectedPortfolio)
                        reloadPortfolios()
                    }
                }
            }

            // === Holdings List ===
            Text {
                text: "Your Holdings"
                font.bold: true
                font.pointSize: 10
            }

            Column {
                id: contentCol
                width: parent.width
                spacing: units.gu(1)

                Repeater {
                    model: holdingsModel
                    delegate: PortfolioItem {
                        coinName: modelData.coin_symbol
                        coinSymbol: modelData.coin_symbol
                        quantity: modelData.amount
                        currentPrice: "" // TODO: link with live data
                    }
                }
            }
        }
    }

    // === Dialog: Create Portfolio ===
    Dialog {
        id: newPortfolioDialog
        modal: true
        focus: true
        title: "Create New Portfolio"

        Column {
            spacing: units.gu(1)
            padding: units.gu(1)

            TextField {
                id: newPortfolioName
                placeholderText: "Enter portfolio name"
            }

            Row {
                spacing: units.gu(2)
                Button {
                    text: "Create"
                    onClicked: {
                        if (newPortfolioName.text.length > 0) {
                            DB.addPortfolio(newPortfolioName.text)
                            newPortfolioName.text = ""
                            newPortfolioDialog.close()
                            reloadPortfolios()
                        }
                    }
                }
                Button {
                    text: "Cancel"
                    onClicked: newPortfolioDialog.close()
                }
            }
        }
    }

    // === Dialog: Add Coin ===
    Dialog {
        id: addCoinDialog
        modal: true
        focus: true
        title: "Add Coin to Portfolio"

        Column {
            spacing: units.gu(1)
            padding: units.gu(1)

            TextField {
                id: coinSymbolField
                placeholderText: "Coin Symbol (e.g. BTC)"
            }

            TextField {
                id: coinAmountField
                placeholderText: "Amount (e.g. 2.5)"
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            Row {
                spacing: units.gu(2)

                Button {
                    text: "Add"
                    onClicked: {
                        if (selectedPortfolio !== -1 && coinSymbolField.text && coinAmountField.text) {
                            DB.addHolding(selectedPortfolio, coinSymbolField.text, parseFloat(coinAmountField.text))
                            coinSymbolField.text = ""
                            coinAmountField.text = ""
                            addCoinDialog.close()
                            loadHoldingsForPortfolio(selectedPortfolio)
                        }
                    }
                }

                Button {
                    text: "Cancel"
                    onClicked: addCoinDialog.close()
                }
            }
        }
    }

    // === Properties ===
    property var portfolioNames: []
    property var portfolioIds: []
    property int selectedPortfolio: -1
    property var holdingsModel: []

    // === Functions ===
    Component.onCompleted: reloadPortfolios()

    function reloadPortfolios() {
        var portfolios = DB.getPortfolios()
        portfolioNames = portfolios.map(p => p.name)
        portfolioIds = portfolios.map(p => p.id)
        if (portfolioIds.length > 0) {
            selectedPortfolio = portfolioIds[0]
            portfolioSelector.currentIndex = 0
            loadHoldingsForPortfolio(selectedPortfolio)
        } else {
            holdingsModel = []
        }
    }

    function loadHoldingsForPortfolio(portfolioId) {
        holdingsModel = DB.getHoldings(portfolioId)
    }
}
