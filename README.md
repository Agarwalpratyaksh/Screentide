# Screentide 🌊

A highly customizable, responsive, and minimalist screentime tracking widget for the **KDE Plasma 6** Desktop Environment, powered by the local, open-source **[ActivityWatch](https://activitywatch.net/)** engine.

Screentide lets you visualize your daily computer usage total, hourly activity charts, and top applications at a glance, directly from your desktop or panel.

---

## 🚀 Key Features

*   **Responsive Layout Reflow**:
    *   **Dual Mode Layout**: Smoothly transitions between a vertical **Portrait** layout and a side-by-side **Landscape** layout on resize.
    *   **Adaptive App Grid**: Top applications automatically reflow between **1-column** and **2-column** layouts depending on widget width to prevent layout squishing.
    *   **Fluid Typography**: Header text and label sizes automatically scale down on compact widget sizes to avoid text clipping.
*   **System Theme Matching & Color Engine**:
    *   **System Accent Colors**: Automatically match your system theme accent colors (such as wallpaper-based accent schemes) with programmatic gradients, or bypass gradients entirely with **Solid Color** mode.
    *   **Manual Palette Picker**: Customize colors (Background, Border, Bar Gradients, Hover States) visually using the native KDE system color dialog or hex input fields.
*   **Dynamic Hour Grouping**:
    *   Group hourly usage bars into **1-hour, 2-hour, 3-hour, 4-hour, or 6-hour** intervals. It is perfect for shrinking widget sizes down to fewer bars without losing details.
    *   Bar widths scale dynamically to zero-overlap, ensuring visual clarity even on narrow screens.
*   **Application Blacklisting**:
    *   A comma-separated exclusion filter to hide background processes, system lock screens, or desktop launchers (e.g. `krunner, lockscreen, plasmashell`) from your stats.
*   **Robust Offline Recovery**:
    *   If `aw-server` is stopped or unreachable, Screentide displays a clean warning screen with an instant **Retry** button so you can re-connect as soon as the service is back online.

---

## 📋 Prerequisites

Before installing the widget, you need **ActivityWatch** running on your local machine:

1.  **Install ActivityWatch**:
    *   **Arch Linux**: `yay -S activitywatch-bin`
    *   **Fedora**: `sudo dnf install activitywatch`
    *   **Debian/Ubuntu**: Download the `.deb` package or tarball from the [ActivityWatch Releases page](https://github.com/ActivityWatch/activitywatch/releases).
2.  **Start ActivityWatch**:
    *   Run `aw-qt` or start it as a background system service.
    *   Verify it is running by visiting the local dashboard at: [http://localhost:5600](http://localhost:5600).

---

## 🛠️ Installation & Setup

### Method 1: Cloned Installation (Recommended)

Since the repository is structured as a direct package, you can clone and register it using the native KDE Plasma package manager:

```bash
# 1. Clone the repository
git clone https://github.com/Agarwalpratyaksh/Screentide.git
cd Screentide

# 2. Install the widget package locally
kpackagetool6 --type Plasma/Applet --install .
```

### Method 2: Manual Installation (Alternative)

If you prefer to copy the files manually into your local user widgets directory:

```bash
# 1. Create the destination directory
mkdir -p ~/.local/share/plasma/plasmoids/org.kde.screentide.widget

# 2. Clone the repository and copy the files
git clone https://github.com/Agarwalpratyaksh/Screentide.git
cp -r Screentide/* ~/.local/share/plasma/plasmoids/org.kde.screentide.widget/
```

---

## 🎮 How to Add the Widget

1.  Right-click your KDE Desktop wallpaper and select **Add Widgets...** (or press `Meta` + `A`).
2.  Search for **"Screentide"**.
3.  Drag and drop the widget onto your panel or desktop.

---

## ⚙️ Customization Options

Right-click the widget and click **"Configure Screentide..."** to customize your setup:

1.  **Background & Borders**: Visual styles, opacity sliders, border width, and rounded corners.
2.  **Layout & Sizing**: Header toggles, list sizing limits, bar width/radius, and hour grouping choices.
3.  **Typography**: Scalable text modifiers and custom font family overrides (e.g. *JetBrains Mono*, *Inter*).
4.  **Filters & Exclusions**: Input a comma-separated list of application names to ignore.
5.  **Time Schedule**: Adjust the starting hour of your logical day tracking (e.g. starting at 6:00 AM instead of midnight).
6.  **Chart Theme Colors**: Turn on system accent colors, toggle solid bar color mode, or build custom visual gradients.

---

## 🛠️ Development & Local Testing

To update files and test your edits live:

```bash
# 1. Sync files to the local plasmoid directory
cp -rv * ~/.local/share/plasma/plasmoids/org.kde.screentide.widget/

# 2. Clear QML caching and reload configs
rm -rf ~/.cache/qmlcache/* && kbuildsycoca6

# 3. Restart the Plasma shell to load updates
plasmashell --replace & disown
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
