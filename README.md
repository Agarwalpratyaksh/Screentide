# Screentide 🌊

A highly customizable, responsive, and minimalist screentime tracking widget for the **KDE Plasma 6** Desktop Environment, powered by the local, open-source **[ActivityWatch](https://activitywatch.net/)** engine.

Screentide lets you visualize your daily computer usage total, hourly activity charts, and top applications at a glance, directly from your desktop or panel.

<p align="center">
  <table border="0">
    <tr>
      <td align="center" width="50%">
        <img src="screenshots/landscape_purple_minimal.jpeg" alt="Landscape Purple Minimal" width="100%"/>
        <br>
      </td>
      <td align="center" width="50%">
        <img src="screenshots/landscape_dark_red.jpeg" alt="Landscape Dark Red" width="100%"/>
        <br>
      </td>
    </tr>
    <tr>
      <td align="center" width="50%">
        <img src="screenshots/portrait_sunset_orange.jpeg" alt="Portrait Sunset Orange" width="100%"/>
        <br>
      </td>
      <td align="center" width="50%">
        <img src="screenshots/portrait_anime_green.jpeg" alt="Portrait Anime Green" width="100%"/>
        <br>
      </td>
    </tr>
  </table>
</p>

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
    *   Please refer to the [Official ActivityWatch Website](https://activitywatch.net/) for platform-specific installation instructions.
    *   *Quick tip:* On Arch Linux, run `yay -S activitywatch-bin`; on Fedora, run `sudo dnf install activitywatch`. For Debian/Ubuntu, download the package from the [ActivityWatch Releases page](https://github.com/ActivityWatch/activitywatch/releases).
2.  **Start ActivityWatch**:
    *   Run `aw-qt` or start it as a background system service.
    *   Verify it is running by visiting the local dashboard at: [http://localhost:5600](http://localhost:5600).

---

## 🛠️ Installation & Setup

### Method 1: Graphical Installer (KDE Store / Discover)

Users can install it instantly without the command line:
1. Right-click your desktop wallpaper and select **Add Widgets...**
2. Click **Get New Widgets** -> **Download New Plasma Widgets**.
3. Search for **"Screentide"**.
4. Click **Install**, then drag it onto your panel or desktop.

### Method 2: Cloned Installation (CLI)

Since the repository is structured as a direct package, you can clone and register it using the native KDE Plasma package manager:

```bash
# 1. Clone the repository
git clone https://github.com/Agarwalpratyaksh/Screentide.git
cd Screentide

# 2. Install the widget package locally
kpackagetool6 --type Plasma/Applet --install .

# To upgrade an already installed version:
kpackagetool6 --type Plasma/Applet --upgrade .
```

### Method 3: Direct `.plasmoid` Installation (KDE Store Download)

If you downloaded the compiled `screentide.plasmoid` package directly from the [KDE Store website](https://www.opendesktop.org/p/2361910/), you can install it using:

```bash
# Install the downloaded plasmoid file
kpackagetool6 --type Plasma/Applet --install screentide.plasmoid

# To upgrade an already installed version:
kpackagetool6 --type Plasma/Applet --upgrade screentide.plasmoid
```

### Method 4: Manual Installation (Alternative)

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
