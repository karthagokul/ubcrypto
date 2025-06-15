// qml/Main.qml
import QtQuick 2.7
import Lomiri.Components 1.3

MainView {
    id: mainView
    applicationName: "UBCrypto"
    property int selectedTab: 0

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
        anchors.leftMargin: units.gu(1)
        anchors.rightMargin: units.gu(1)
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: units.gu(7)
        color: "#f5f5f5"
        border.color: "#ccc"

        Row {
            anchors.centerIn: parent
            anchors.left: navBar.left
            spacing: units.gu(1)

            Repeater {
                model: [
                    {
                        name: "Dashboard"
                    },
                    {
                        name: "Portfolio"
                    },
                    {
                        name: "Settings"
                    },
                    {
                        name: "About"
                    }
                ]

                delegate: MouseArea {
                    width: units.gu(10)
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
                            font.pixelSize: units.gu(1.8)
                            font.bold: selectedTab === index
                            color: selectedTab === index ? LomiriColors.orange : "#444"
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
            return settingsPage;
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

    Component.onCompleted: console.log("UBCrypto started")
}
