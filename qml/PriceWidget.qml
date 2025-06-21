// FormattedPrice.qml
import QtQuick 2.7
import QtQuick.Controls 2.2
// If this component will be used inside QtQuick.Layouts (like RowLayout, ColumnLayout),
// then you might want to import Layouts here as well.
// import QtQuick.Layouts 1.3 // Uncomment if needed

Text {
    id: root

    // Public property to set the price
    property real value: 0.0

    // Optional: Public property for the currency symbol (e.g., "$", "€")
    property string currencySymbol: "$"

    // Inherit common font/color properties from where it's used,
    // or set defaults here:
    font.pixelSize: units.gu(2) // Assuming 'units' is available in its usage context
    font.bold: true
    color: "#000"

    // If this component is placed within a Layout (like Column or RowLayout)
    // that manages its width, setting width to parent.width ensures it
    // takes the available space, allowing horizontalAlignment to work.
    width: parent ? parent.width : implicitWidth // Default to parent's width if available, else implicit
    horizontalAlignment: Text.AlignRight // Align the text content to the right

    // Function to calculate the appropriate number of decimal places
    function getDecimalPlaces(num) {
        if (num === 0) {
            return 2; // For zero, show "0.00"
        }
        let absNum = Math.abs(num);

        // Standard fiat currency-like prices
        if (absNum >= 100) return 2; // e.g., $123.45
        if (absNum >= 1) return 4;   // e.g., $1.2345

        // Cryptocurrency prices with leading zeros
        if (absNum >= 0.001) return 6;   // e.g., $0.001234
        if (absNum >= 0.000001) return 8; // e.g., $0.00000123
        if (absNum >= 0.000000001) return 10; // e.g., $0.0000000123
        if (absNum >= 0.000000000001) return 12; // e.g., $0.000000000123
        if (absNum >= 0.000000000000001) return 15; // For extremely small numbers (like 0.00000000000000123)

        // For even smaller numbers, show a high number of decimals
        return 18; // Default for extremely tiny values
    }

    // The text property will dynamically update based on the 'value'
    text: {
        let decimals = getDecimalPlaces(value);
        // Ensure toFixed handles potential floating point inaccuracies
        // by first rounding to the necessary precision if needed, though
        // toFixed usually handles it fine for display.
        return currencySymbol + value.toFixed(decimals);
    }
}
