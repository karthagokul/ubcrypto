import QtQuick 2.7
import QtQuick.Controls 2.2
import Lomiri.Components 1.3
import "theme.js" as AppTheme

Rectangle {
    id: filterNavBar
    height: units.gu(7) // Increased for better visibility/touch target
    color: "#f5f5f5"
    border.color: "#ccc"
    border.width: 1 // Add a border to make the bar itself visible

    // === Inputs ===
    property var modelData: [
        { label: "All", key: "all" },
        { label: "Gainers", key: "gainers" },
        { label: "Losers", key: "losers" },
        { label: "Favorites", key: "favorites" },
        { label: "Watchlist", key: "watchlist" },
        { label: "Top 10", key: "top10" }
    ]
    property string selectedKey: "all"

    // === Output ===
    signal filterSelected(string key)

    // DEBUGGING: Log when modelData changes and its content
    onModelDataChanged: {
        console.log("FilterNavBar: modelData changed. Length:", modelData.length);
        if (modelData.length > 0) {
            console.log("First item in modelData:", JSON.stringify(modelData[0]));
        }
    }

    // === Horizontal scroll wrapper ===
    Flickable {
        anchors.fill: parent
        // Ensure some horizontal padding for the content within the flickable
        anchors.leftMargin: units.gu(2)
        anchors.rightMargin: units.gu(2)

        contentWidth: buttonRow.implicitWidth // Use implicitWidth for Row's natural size
        interactive: true
        flickableDirection: Flickable.HorizontalFlick
        clip: true // Ensure children are clipped to Flickable's bounds

        // DEBUGGING: Log Flickable's size and contentWidth
        onWidthChanged: console.log("Flickable Width:", width);
        onHeightChanged: console.log("Flickable Height:", height);
        onContentWidthChanged: console.log("Flickable ContentWidth:", contentWidth);

        Row {
            id: buttonRow
            spacing: units.gu(2)
            anchors.verticalCenter: parent.verticalCenter

            // DEBUGGING: Log Row's size
            onImplicitWidthChanged: console.log("ButtonRow implicitWidth:", implicitWidth);
            onWidthChanged: console.log("ButtonRow actual Width:", width);
            onHeightChanged: console.log("ButtonRow Height:", height);

            Repeater {
                model: filterNavBar.modelData // Explicitly refer to the parent's modelData property

                // DEBUGGING: Log Repeater's model count
                onModelChanged: console.log("Repeater model count:", model ? model.length : 0);

                delegate: MouseArea {
                    // Give the delegate an ID for easier debugging
                    id: delegateRoot

                    width:filterNavBar.width/4
                    height: filterNavBar.height

                    // DEBUGGING: Log delegate's size and visibility
                    onImplicitWidthChanged: console.log("Delegate implicitWidth:", implicitWidth, "label:", model.label);
                    onHeightChanged: console.log("Delegate Height:", height, "label:", model.label);
                    onVisibleChanged: console.log("Delegate Visible:", visible, "label:", model.label);
                    onXChanged: console.log("Delegate X:", x, "label:", model.label);


                    onClicked: {
                        filterNavBar.selectedKey = model.key
                        filterNavBar.filterSelected(model.key)
                    }

                    Rectangle {
                        anchors.fill: parent
                        width:filterNavBar.width/4
                        color: "red"
                        border.color: filterNavBar.selectedKey === model.key ? "white" : "transparent"
                        border.width: filterNavBar.selectedKey === model.key ? units.dp(2) : 0
                        radius: units.dp(4)

                        Text {
                            id: buttonText
                            text: model.label
                            anchors.centerIn: parent
                            anchors.fill: parent
                            font.pixelSize: units.gu(1.8)
                            font.bold: filterNavBar.selectedKey === model.key
                            color: filterNavBar.selectedKey === model.key ? "white" : "#444"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                       }
                    }
                }
            }
        }
    }
}
