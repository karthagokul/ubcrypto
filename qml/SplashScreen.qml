// SplashScreen.qml
import QtQuick 2.7
import Lomiri.Components 1.3 // For units.gu() and potentially other styling
import QtQuick.Controls 2.2 // For BusyIndicator (optional)

Rectangle {
    id: splashScreen
    anchors.fill: parent // Make it fill the entire window
    color: "#F5F5F5" // A clean, light grey background

    // Signal to notify the parent (your main application) when the splash screen is done
    signal finished()

    // --- Splash Screen Content ---
    Column {
        anchors.centerIn: parent // Center the content vertically and horizontally
        spacing: units.gu(2) // Spacing between elements
        width: parent.width * 0.8 // Take up 80% of parent width for content
        height: childrenRect.height // Automatically adjust height to fit content
        Layout.alignment: Qt.AlignHCenter // Ensure content within column is horizontally centered

        Image {
            source: "qrc:///images/app_logo.png" // <--- IMPORTANT: Replace with your actual app logo path
            width: units.gu(15) // Adjust size as needed
            height: units.gu(15)
            fillMode: Image.PreserveAspectFit
            smooth: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "Crypto Tracker" // <--- Your Application Name
            font.pixelSize: units.gu(4)
            font.bold: true
            color: "#333" // Dark grey text
            horizontalAlignment: Text.AlignHCenter
            width: parent.width // Crucial for horizontalAlignment to work
        }

        Text {
            text: "Your Market Insights, Instantly." // <--- A catchy tagline or slogan
            font.pixelSize: units.gu(2.2)
            color: "#666" // Medium grey text
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
        }

        // Optional: A subtle loading indicator
        BusyIndicator {
            running: true
            size: units.gu(3) // Size of the indicator
            anchors.horizontalCenter: parent.horizontalCenter
            Layout.topMargin: units.gu(3) // Space above the indicator
        }
    }

    // --- Timer to control splash screen duration ---
    Timer {
        id: splashTimer
        interval: 1000 // 1000 milliseconds = 1 second
        running: true // Start the timer immediately when the component loads
        onTriggered: {
            splashScreen.finished() // Emit the signal when the timer finishes
            running = false // Stop the timer
        }
    }
}
