// qml/PortfolioPage.qml
import QtQuick 2.7
import Lomiri.Components 1.3
import "theme.js" as AppTheme

Page {
    id: portfolioPage
    header: PageHeader {
        id: header
        title: "Settings"
    }

    Flickable {
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        contentHeight: contentCol.height
    }
}
