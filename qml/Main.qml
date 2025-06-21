// qml/Main.qml
import QtQuick 2.7
import Lomiri.Components 1.3
import io.thp.pyotherside 1.4
import "datastore.js" as DB

MainView {
    id: mainView
    applicationName: "ubcrypto"
    property int selectedTab: 0

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl("../src/"));
            importModule("cli", function () {
                python.call("cli.start_background_sync",  function (result) {
                    console.log("Started")
                });
            });
        }

        onError: function (errorName, errorMessage, traceback) {
            console.log("Python Error:", errorName, errorMessage, traceback);
        }
    }

    // Loader section (main content)
    Loader {
        id: pageLoader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: navBar.top
        sourceComponent: getPage(selectedTab)
    }

    // Bottom nav bar (no overlap)
    Rectangle {
        id: navBar
        anchors.left: parent.left
        //anchors.leftMargin: units.gu(1)
        //anchors.rightMargin: units.gu(1)
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: units.gu(7)
        color: "#1c1c1e" // Deep charcoal black (used in macOS/iOS dark mode)
        border.color: "#333" // Subtle border for separation
        Row {
            anchors.centerIn: parent
            anchors.left: navBar.left
            spacing: units.gu(1)

            Repeater {
                model: [
                    {
                        name: "DASHBOARD"
                    },
                    {
                        name: "PORTFOLIO"
                    },
                    {
                        name: "ABOUT"
                    }
                ]

                delegate: MouseArea {
                    width: units.gu(14)
                    height: navBar.height
                    onClicked: {
                        selectedTab = index;
                        pageLoader.sourceComponent = getPage(selectedTab);
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"

                        Text {
                            text: modelData.name
                            anchors.centerIn: parent
                            font.pixelSize: units.gu(2)
                            font.bold: true
                            color: selectedTab === index ? LomiriColors.orange : "#f0f0f0"
                        }
                    }
                }
            }
        }
    }

    // Pages
    function getPage(index) {
        if (index === 0)
            return dashboardPage;
        if (index === 1)
            return portfolioPage;
        if (index === 2)
            return aboutPage;
        return aboutPage;
    }

    Component {
        id: dashboardPage
        DashboardPage {}
    }
    Component {
        id: portfolioPage
        PortfolioPage {}
    }
    Component {
        id: settingsPage
        SettingsPage {}
    }
    Component {
        id: aboutPage
        AboutPage {}
    }

    Component.onCompleted:
    {
        DB.initializeDatabase()
        console.log("UBCrypto started")
    }
}
