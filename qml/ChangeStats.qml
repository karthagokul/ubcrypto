import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3 // IMPORTANT: Need this for RowLayout and GridLayout properties

Item {
    id: changeBox
    property real change1h: 0
    property real change24h: 0
    property real change7d: 0
    property real change30d: 0

    width: parent.width // Component takes the full width available from its parent
    height: implicitHeight // Item's height will be determined by the Grid content

    GridLayout {
        id: statGrid
        columns: 2 // We have 2 main columns for the layout (e.g., 1h block and 24h block)
        columnSpacing: units.gu(1) // Spacing between stat blocks (e.g., 1h and 24h)
        rowSpacing: units.gu(0.8)   // Spacing between rows of stat blocks (e.g., 1st row vs 2nd row)
        anchors.fill: parent // Makes the grid fill the entire changeBox item
        anchors.margins: units.gu(0.5)

        // --- First Row ---

        // Container for 1h stat (occupies first cell in first row)
        RowLayout {
            Layout.fillWidth: true // Make this RowLayout fill its grid cell's width
            Text {
                text: "1h:"
                color: "#AAA"
                font.pixelSize: units.gu(1.2)
            }
            Text {
                text: (change1h >= 0 ? "+" : "") + change1h.toFixed(2) + "%"
                color: change1h >= 0 ? "green" : "red"
                font.pixelSize: units.gu(1.2)
               // font.bold: true
                Layout.fillWidth: true // Make value text fill remaining space in this RowLayout
                horizontalAlignment: Text.AlignRight
            }
        }

        // Container for 24h stat (occupies second cell in first row)
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "24h:"
                color: "#AAA"
                font.pixelSize: units.gu(1.2)
            }
            Text {
                text: (change24h >= 0 ? "+" : "") + change24h.toFixed(2) + "%"
                color: change24h >= 0 ? "green" : "red"
                font.pixelSize: units.gu(1.2)
               // font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
            }
        }

        // --- Second Row ---

        // Container for 7d stat (occupies first cell in second row)
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "7d:"
                color: "#AAA"
                font.pixelSize: units.gu(1.2)
            }
            Text {
                text: (change7d >= 0 ? "+" : "") + change7d.toFixed(2) + "%"
                color: change7d >= 0 ? "green" : "red"
                font.pixelSize: units.gu(1.2)
               // font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
            }
        }

        // Container for 30d stat (occupies second cell in second row)
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "30d:"
                color: "#AAA"
                font.pixelSize: units.gu(1.2)
            }
            Text {
                text: (change30d >= 0 ? "+" : "") + change30d.toFixed(2) + "%"
                color: change30d >= 0 ? "green" : "red"
                font.pixelSize: units.gu(1.2)
               //  font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
