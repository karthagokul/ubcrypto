import QtQuick 2.7
import Lomiri.Components 1.3
import io.thp.pyotherside 1.4

Page {
    id: dashboardPage
    header: PageHeader {
        id: header
        title: "Portfolio"
    }

    property var coinModel: []

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl("../src/"));
            importModule("api_client", function () {
                python.call("api_client.get_coins", [50], function (result) {
                    coinModel = result;
                });
            });
        }

        onError: function (errorName, errorMessage, traceback) {
            console.log("Python Error:", errorName, errorMessage, traceback);
        }
    }

    Flickable {
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        contentHeight: coinList.height

        Column {
            id: coinList
            width: parent.width

            Repeater {
                model: coinModel
                delegate: CoinCard {
                    coinName: modelData.name
                    coinSymbol: modelData.symbol
                    price: modelData.price.toFixed(2)
                    change24h: modelData.change24h !== null ? (modelData.change24h >= 0 ? "+" : "") + modelData.change24h.toFixed(2) + "%" : "N/A"
                    coinImage: modelData.image  // only if you're fetching the image URL
                }
            }
        }
    }
}
