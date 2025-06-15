// qml/AboutPage.qml
import QtQuick 2.7
import Lomiri.Components 1.3

Page {
    id: aboutPage
    header: PageHeader {
        id: header
        title: "About UBCrypto"
    }

    Flickable {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        contentHeight: contentCol.height
        anchors.margins: units.gu(2)

        Column {
            id: contentCol
            width: parent.width
            spacing: units.gu(1)
            anchors.margins: units.gu(2)

            Label {
                text: "UBCrypto is a lightweight cryptocurrency tracking app designed for Ubuntu Touch."
                width:parent.width
                wrapMode: Text.WordWrap
            }

            Label {
                text: "Features:"
                font.bold: true
            }

            Label {
                text: "\u2022 Live price tracking\n\u2022 Personal portfolio view\n\u2022 Clean UI with offline support\n\u2022 Built with Qt/QML and Python"
                wrapMode: Text.WordWrap
            }
            Label {
                text: "https://github.com/karthagokul/ubcrypto"
                font.italic: true
                wrapMode: Text.WordWrap
            }

            Label {
                text: "Developed by Gokul Kartha <kartha.gokul@gmail.com>"
                font.italic: true
                wrapMode: Text.WordWrap
            }

            Label {
                text: "Version 1.0.0"
                color: "#888"
            }
        }
    }
}
