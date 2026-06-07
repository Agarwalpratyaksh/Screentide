# Screentide (KDE Plasma 6 Widget)

A highly customizable, responsive, and minimalist screentime tracking widget for the **KDE Plasma 6 Desktop Environment**, powered by the local, open-source **[ActivityWatch](https://activitywatch.net/)** engine.

It displays your daily computer usage total, hourly activity charts, and the top applications you've active with dynamic progress bars.

---

## Key Features

*   **Responsive Layout reflow**:
    *   Automatically transitions between a vertical **Portrait** layout and a side-by-side **Landscape** layout on resize.
    *   App lists reflow dynamically between **1-column** and **2-column** layouts depending on widget width to prevent squishing.
    *   Typography automatically scales down on smaller widget sizes to avoid text clipping.
*   **Deep Personalization Engine (Ricer-Friendly)**:
    *   Change border radius, border width, background color, and card opacity.
    *   Separate opacity layers keep background cards translucent without diluting the readability of text or icons.
    *   Fully customizable typography (override fonts with system variants e.g., *JetBrains Mono*, *Fira Code* or *Inter* and adjust scale).
    *   Customizable hourly chart bar widths and corner radius.
    *   Toggle display parameters (show/hide app percentages, title headers, etc.).
*   **Interactive Color Dialog Picker**:
    *   Select color parameters (chart bar gradients, background, and outlines) visually using the native KDE system color dialog or manually by typing hex codes.
*   **Application Blacklist Filtering**:
    *   A comma-separated exclusion filter to hide distracting background processes or system panels (e.g., `krunner, lockscreen, plasmashell`) from your stats.
*   **Time Schedules**:
    *   Supports a logical daily offset start (e.g., track a 24-hour cycle beginning at 6 AM instead of midnight).
*   **Robust Offline Error Recovery**:
    *   If `aw-server` is down or unreachable, the widget displays a clean offline recovery state with troubleshooting steps and a **Retry** button.

---

## Prerequisites

1.  **KDE Plasma 6**
2.  **ActivityWatch running locally**
    *   Install it via your distribution package manager or download it directly from the [official site](https://activitywatch.net/).
    *   Ensure the local server is running (default: `http://localhost:5600`).

---

## Installation & Deployment

### Method 1: Installing via GUI (KDE Store / Discover)

Once published, users can install it instantly from the desktop:
1.  Right-click your desktop background and select **Add Widgets...**
2.  Click **Get New Widgets** -> **Download New Plasma Widgets**.
3.  Search for `Screentide`.
4.  Click **Install**, then drag it onto your desktop panel or desktop grid.

---

### Method 2: Command Line (Cloning from Source)

Clone the repository and install it using the KDE Plasma package management utility:

```bash
# Clone the repository
git clone https://github.com/yourusername/screentide-widget.git
cd screentide-widget

# Install the widget package globally
kpackagetool6 --type Plasma/Applet --install package/
```

#### Manual File Copy (Alternative)
You can also manually copy the `package` folder to your local Plasma configuration directories:

```bash
mkdir -p ~/.local/share/plasma/plasmoids/org.kde.screentide.widget
cp -r package/* ~/.local/share/plasma/plasmoids/org.kde.screentide.widget/
```

---

## Customization & Options

Right-click the widget and click **"Configure Screentide..."** to adjust your setup:

1.  **Background & Borders**: Visual styles, opacity, border width, and border radius.
2.  **Layout & Sizing**: Header toggles, list sizing, bar width/radius, and percentage settings.
3.  **Typography**: Scale modifiers and font family overrides.
4.  **Filters & Exclusions**: Input a comma-separated list of application names to ignore.
5.  **Time Schedule**: Adjust the starting hour of your logical day tracking.
6.  **Chart Theme Colors**: Customize the active and hovered gradients for bars.
7.  **Maintenance Actions**: Click **Reset to Default Settings** to wipe custom parameters and revert to factory configurations.

---

## Development & Reloading

If you are developing or modifying the widget code locally:

```bash
# 1. Sync modifications to your local plasmoids directory:
cp -rv package/* ~/.local/share/plasma/plasmoids/org.kde.screentide.widget/

# 2. Clear QML caches & rebuild system package list:
rm -rf ~/.cache/qmlcache/* && kbuildsycoca6

# 3. Restart the KDE Desktop shell to apply:
plasmashell --replace & disown
```

---

## License

This project is licensed under the [MIT License](LICENSE) (or GPL-3.0) — feel free to share, modify, and rice it as you wish!
