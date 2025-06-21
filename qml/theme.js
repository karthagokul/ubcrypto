// theme.js
// This makes the JS file a singleton, loaded once and shared across components.
.pragma library

// Function to get theme-dependent colors
// 'currentThemeName' will typically be 'theme.name' from Ubuntu.Components
function getThemeColors(currentThemeName) {
    // Define the color palette for the Light Theme
    var lightPalette = {
        background: "#f0f2f5",      // General page background (light gray)
        cardBackground: "#ffffff",  // Background for news cards (white)
        textColorPrimary: "#333333",// Dark gray for main text (titles, descriptions)
        textColorSecondary: "#666666",// Medium gray for secondary text (dates)
        linkColor: "#007bff",       // Standard blue for links/buttons
        separatorColor: "#e0e0e0",  // Light gray for separators
        buttonBackground: "#007bff",// Primary button background (blue)
        buttonText: "#ffffff",      // Text on primary button (white)
        highlight: "#0056b3"        // Darker blue for pressed states (primary button)
    };

    // Define the color palette for the Dark Theme
    var darkPalette = {
        background: "#1e1e1e",      // Very dark gray for page background
        cardBackground: "#2a2a2a",  // Slightly lighter dark gray for news cards
        textColorPrimary: "#f0f0f0",// NEAR-WHITE for main text - GOOD CONTRAST
        textColorSecondary: "#b0b0b0",// LIGHTER GRAY for secondary text - GOOD CONTRAST
        linkColor: "#76b900",       // Greenish-yellow for links/buttons (stands out on dark)
        separatorColor: "#4a4a4a",  // Darker gray for separators
        buttonBackground: "#76b900",// Primary button background (greenish-yellow)
        buttonText: "#f0f0f0",      // ***CORRECTED: Near-white for button text in dark mode for better contrast***
        highlight: "#5f9500"        // Darker greenish-yellow for pressed states
    };

    // Determine which palette to return based on the current theme name
    if (currentThemeName === "Lomiri.Components.Themes.SuruDark") {
        //console.log("---------->Current theme requested and returning darkPalette: " + currentThemeName);
        return darkPalette; // Return darkPalette when the theme IS SuruDark
    } else {
        // Default to light palette for any other theme (including Suru Light)
        //console.log("---------->Current theme requested and returning lightPalette: " + currentThemeName);
        return lightPalette; // Return lightPalette when the theme IS NOT SuruDark
    }
}
