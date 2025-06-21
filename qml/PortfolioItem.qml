import QtQuick 2.7
import Lomiri.Components 1.3

ListItem {
    id: portfolioCard
    width: parent ? parent.width : Screen.width
    height: units.gu(10)
    color: "#fff"
    anchors.margins: units.gu(0.5)

    // Input Properties
    property string coinName: ""
    property string coinSymbol: ""
    property string price: ""
    property string total_value: ""
    property url coinImage: ""
    property real quantity: 0
    property string recordId

    signal editRequested(string recordId)
    signal deleteRequested(string recordId)

    trailingActions: ListItemActions {
           actions: [
               Action {
                   iconName: "edit"
                   onTriggered: editRequested(recordId)
               },
               Action {
                   iconName: "delete"
                   onTriggered: deleteRequested(recordId)
               }
           ]
       }


    Row {
        anchors.fill: parent
        anchors.margins: units.gu(1)
        spacing: units.gu(2)

        // === Left Section: Icon + Name + Symbol ===
        Item {
            width: parent.width * 0.5
            height: parent.height

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: units.gu(1)

                Image {
                    source: coinImage
                    width: units.gu(4)
                    height: units.gu(4)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    visible: coinImage !== ""
                }

                Column {
                    spacing: units.gu(0.3)
                    width: parent.width * 0.35

                    Text {
                        text: coinName
                        font.pixelSize: units.gu(2.2)
                        //font.bold: true
                        color: "#222"
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        text: coinSymbol.toUpperCase()
                        font.pixelSize: units.gu(1.8)
                        color: "#666"
                    }
                }
            }
        }

        // === Right Section: Qty, Price, Total ===
        Item {
            width: parent.width * 0.45
            height: parent.height

            Column {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: units.gu(0.3)

                Text {
                    text: "Qty: " + quantity
                    font.pixelSize: units.gu(1.5)
                    color: "#333"
                    horizontalAlignment: Text.AlignRight
                }

                PriceWidget {
                    text: "Unit: $" + Number(price).toFixed(2)
                    font.bold:false
                    font.pixelSize: units.gu(2)
                    color: "#333"
                    horizontalAlignment: Text.AlignRight
                }

                PriceWidget {
                    text: "Total: $" + Number(total_value).toFixed(2)
                    font.bold:false
                    font.pixelSize: units.gu(2)
                    color: "#333"
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }
}
