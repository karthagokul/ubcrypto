import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Controls 2.2

Dialog {
    id: addCoinDialog
    modal: true
    focus: true
    title: "Add Coin to Portfolio"

    property alias symbolField: coinSymbolField
    property alias amountField: coinAmountField
    signal coinAdded(string symbol, real amount)

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
                    if (coinSymbolField.text && coinAmountField.text) {
                        coinAdded(coinSymbolField.text, parseFloat(coinAmountField.text));
                        coinSymbolField.text = "";
                        coinAmountField.text = "";
                        addCoinDialog.close();
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
