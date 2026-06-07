import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root
    
    // Disable default system background shadow/glow to prevent double-borders
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    
    property int triggerUpdate: 0
    property string totalTimeStr: "..."
    property int dayOffset: 0
    property string dateLabel: "Today"
    property var dataCache: ({})
    property real maxAppDuration: 1
    
    // Offline status tracking
    property bool isServerOffline: false
    
    // Custom font configuration
    property string customFontFamily: plasmoid.configuration.fontFamily !== "" ? plasmoid.configuration.fontFamily : Kirigami.Theme.defaultFont.family
    
    // Resolved color options (either system theme accent colors or custom settings colors)
    readonly property color resolvedBarColorStart: plasmoid.configuration.useSystemTheme ? Kirigami.Theme.highlightColor : plasmoid.configuration.chartBarColorStart
    readonly property color resolvedBarColorEnd: plasmoid.configuration.useSolidColor ? resolvedBarColorStart : (plasmoid.configuration.useSystemTheme ? Qt.lighter(Kirigami.Theme.highlightColor, 1.25) : plasmoid.configuration.chartBarColorEnd)
    
    readonly property color resolvedBarColorHoverStart: plasmoid.configuration.useSystemTheme ? Qt.lighter(Kirigami.Theme.highlightColor, 1.15) : plasmoid.configuration.chartBarColorHoverStart
    readonly property color resolvedBarColorHoverEnd: plasmoid.configuration.useSolidColor ? resolvedBarColorHoverStart : (plasmoid.configuration.useSystemTheme ? Qt.lighter(Kirigami.Theme.highlightColor, 1.35) : plasmoid.configuration.chartBarColorHoverEnd)
    
    onDayOffsetChanged: {
        updateDateLabel();
        fetchData();
    }
    
    // Watch configuration changes and reload data when relevant settings change
    Connections {
        target: plasmoid.configuration
        function onStartHourChanged() {
            root.dataCache = {};
            root.fetchData();
        }
        function onMaxAppsShownChanged() {
            root.dataCache = {};
            root.fetchData();
        }
        function onShowPercentagesChanged() {
            root.dataCache = {};
            root.fetchData();
        }
        function onBlacklistChanged() {
            root.dataCache = {};
            root.fetchData();
        }
        function onHourStepIndexChanged() {
            root.dataCache = {};
            root.fetchData();
        }
    }
    
    function updateDateLabel() {
        if (dayOffset === 0) {
            dateLabel = "Today";
        } else if (dayOffset === -1) {
            dateLabel = "Yesterday";
        } else {
            var d = new Date();
            d.setDate(d.getDate() + dayOffset);
            dateLabel = d.toLocaleDateString(Qt.locale(), Locale.ShortFormat);
        }
    }
    
    readonly property int hourStep: {
        var steps = [1, 2, 3, 4, 6];
        var idx = plasmoid.configuration.hourStepIndex;
        return (idx >= 0 && idx < steps.length) ? steps[idx] : 1;
    }
    
    property var hourlyData: []
    property real maxHourlyTime: 1
    
    ListModel { id: appsModel }
    
    Timer {
        id: autoRefreshTimer
        interval: 300000 // 5 minutes
        running: true
        repeat: true
        onTriggered: fetchData()
    }
    
    Component.onCompleted: fetchData()
    
    function formatDuration(seconds) {
        var hrs = Math.floor(seconds / 3600);
        var mins = Math.floor((seconds % 3600) / 60);
        if (hrs > 0) return hrs + "h " + mins + "m";
        if (mins > 0) return mins + "m";
        return Math.floor(seconds) + "s";
    }

    function getHourLabel(index) {
        var startHour = plasmoid.configuration.startHour
        var step = root.hourStep
        var startHr = (index * step + startHour) % 24;
        var endHr = ((index + 1) * step + startHour) % 24;
        return formatHourHelper(startHr) + " - " + formatHourHelper(endHr);
    }
    
    function formatHourHelper(h) {
        if (h === 0) return "12 AM";
        if (h === 12) return "12 PM";
        return (h > 12) ? (h - 12) + " PM" : h + " AM";
    }

    function mapIcon(appName) {
        appName = appName.toLowerCase()
        
        // Browsers
        if (appName.indexOf("chrome") !== -1) return "google-chrome"
        if (appName.indexOf("brave") !== -1) return "brave-browser"
        if (appName.indexOf("firefox") !== -1) return "firefox"
        if (appName.indexOf("edge") !== -1 || appName.indexOf("msedge") !== -1) return "microsoft-edge"
        if (appName.indexOf("opera") !== -1) return "opera"
        if (appName.indexOf("vivaldi") !== -1) return "vivaldi"
        if (appName.indexOf("tor") !== -1) return "tor-browser"
        if (appName.indexOf("safari") !== -1) return "safari"
        if (appName.indexOf("chromium") !== -1) return "chromium"
        
        // IDE / Development
        if (appName.indexOf("code") !== -1 || appName.indexOf("vscode") !== -1) return "visual-studio-code"
        if (appName.indexOf("cursor") !== -1) return "cursor"
        if (appName.indexOf("intellij") !== -1 || appName.indexOf("idea") !== -1) return "intellij-idea"
        if (appName.indexOf("webstorm") !== -1) return "webstorm"
        if (appName.indexOf("pycharm") !== -1) return "pycharm"
        if (appName.indexOf("clion") !== -1) return "clion"
        if (appName.indexOf("android") !== -1 || appName.indexOf("studio") !== -1) return "android-studio"
        if (appName.indexOf("sublime") !== -1 || appName.indexOf("subl") !== -1) return "sublime-text"
        if (appName.indexOf("emacs") !== -1) return "emacs"
        if (appName.indexOf("neovim") !== -1 || appName.indexOf("nvim") !== -1) return "nvim"
        if (appName.indexOf("vim") !== -1) return "vim"
        if (appName.indexOf("gitkraken") !== -1) return "gitkraken"
        if (appName.indexOf("github") !== -1) return "github"
        
        // Terminals
        if (appName.indexOf("kitty") !== -1) return "kitty"
        if (appName.indexOf("alacritty") !== -1) return "alacritty"
        if (appName.indexOf("konsole") !== -1) return "konsole"
        if (appName.indexOf("wezterm") !== -1) return "wezterm"
        if (appName.indexOf("terminal") !== -1 || appName.indexOf("term") !== -1 || appName.indexOf("bash") !== -1 || appName.indexOf("zsh") !== -1) return "utilities-terminal"
        
        // Communication
        if (appName.indexOf("slack") !== -1) return "slack"
        if (appName.indexOf("discord") !== -1) return "discord"
        if (appName.indexOf("telegram") !== -1) return "telegram"
        if (appName.indexOf("whatsapp") !== -1) return "whatsapp"
        if (appName.indexOf("teams") !== -1) return "teams"
        if (appName.indexOf("signal") !== -1) return "signal"
        if (appName.indexOf("zoom") !== -1) return "zoom"
        if (appName.indexOf("skype") !== -1) return "skype"
        
        // Email
        if (appName.indexOf("thunderbird") !== -1) return "thunderbird"
        if (appName.indexOf("evolution") !== -1) return "evolution"
        if (appName.indexOf("kmail") !== -1) return "kmail"
        
        // Office & Productivity
        if (appName.indexOf("writer") !== -1) return "libreoffice-writer"
        if (appName.indexOf("calc") !== -1) return "libreoffice-calc"
        if (appName.indexOf("impress") !== -1) return "libreoffice-impress"
        if (appName.indexOf("notion") !== -1) return "notion"
        if (appName.indexOf("obsidian") !== -1) return "obsidian"
        if (appName.indexOf("evernote") !== -1) return "evernote"
        if (appName.indexOf("todoist") !== -1) return "todoist"
        
        // Creative & Media
        if (appName.indexOf("blender") !== -1) return "blender"
        if (appName.indexOf("gimp") !== -1) return "gimp"
        if (appName.indexOf("inkscape") !== -1) return "inkscape"
        if (appName.indexOf("krita") !== -1) return "krita"
        if (appName.indexOf("photoshop") !== -1) return "photoshop"
        if (appName.indexOf("illustrator") !== -1) return "illustrator"
        if (appName.indexOf("figma") !== -1) return "figma"
        if (appName.indexOf("spotify") !== -1) return "spotify"
        if (appName.indexOf("vlc") !== -1) return "vlc"
        if (appName.indexOf("mpv") !== -1) return "mpv"
        if (appName.indexOf("steam") !== -1) return "steam"
        if (appName.indexOf("lutris") !== -1) return "lutris"
        if (appName.indexOf("heroic") !== -1) return "heroic"
        
        // System / Utilities
        if (appName.indexOf("dolphin") !== -1 || appName.indexOf("finder") !== -1) return "system-file-manager"
        if (appName.indexOf("settings") !== -1 || appName.indexOf("preferences") !== -1 || appName.indexOf("control-center") !== -1) return "preferences-system"
        if (appName.indexOf("discover") !== -1) return "plasmadiscover"
        if (appName.indexOf("systemmonitor") !== -1 || appName.indexOf("htop") !== -1 || appName.indexOf("monitor") !== -1) return "utilities-system-monitor"
        if (appName.indexOf("krunner") !== -1) return "krunner"
        if (appName.indexOf("spectacle") !== -1 || appName.indexOf("screenshot") !== -1) return "spectacle"
        
        // Extract icon from desktop app namespace (e.g. org.kde.kcalc -> kcalc)
        if (appName.indexOf(".") !== -1) {
            var parts = appName.split(".");
            var lastPart = parts[parts.length - 1];
            if (lastPart.length > 0) return lastPart;
        }
        
        if (appName.length > 0 && appName !== "unknown") {
            return appName;
        }
        
        return "system-run"
    }

    function fetchData() {
        if (root.dayOffset < 0 && root.dataCache[root.dayOffset] !== undefined) {
            var cached = root.dataCache[root.dayOffset];
            root.totalTimeStr = cached.totalTimeStr;
            root.hourlyData = cached.hourlyData;
            root.maxHourlyTime = cached.maxHourlyTime;
            root.maxAppDuration = cached.maxAppDuration;
            
            appsModel.clear();
            for (var i = 0; i < cached.apps.length; i++) {
                appsModel.append(cached.apps[i]);
            }
            root.triggerUpdate += 1;
            return;
        }

        var xhr = new XMLHttpRequest()
        xhr.open("POST", "http://127.0.0.1:5600/api/0/query/")
        xhr.setRequestHeader("Content-Type", "application/json")
        
        var startHour = plasmoid.configuration.startHour
        var now = new Date()
        var logicalNow = new Date(now.getTime() - startHour * 3600 * 1000)
        var targetDate = new Date(logicalNow.getFullYear(), logicalNow.getMonth(), logicalNow.getDate() + root.dayOffset)
        
        var startOfDay = new Date(targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate(), startHour, 0, 0, 0)
        var endOfDay = new Date(startOfDay.getTime() + 24 * 3600 * 1000 - 1)
        
        var query = "afk = query_bucket(find_bucket(\"aw-watcher-afk_\"));\n" +
                    "window = query_bucket(find_bucket(\"aw-watcher-window_\"));\n" +
                    "not_afk = filter_keyvals(afk, \"status\", [\"not-afk\"]);\n" +
                    "active_window = filter_period_intersect(window, not_afk);\n" +
                    "RETURN = active_window;"
                    
        var payload = { "query": [query], "timeperiods": [startOfDay.toISOString() + "/" + endOfDay.toISOString()] }
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    root.isServerOffline = false;
                    var response = JSON.parse(xhr.responseText)
                    var resultEvents = response[0]
                    if (resultEvents && resultEvents.length > 0 && Array.isArray(resultEvents[0])) resultEvents = resultEvents[0]
                    if (!resultEvents || !resultEvents.length) resultEvents = []
                    
                    var totalSecs = 0
                    var step = root.hourStep
                    var binCount = Math.ceil(24 / step)
                    var hourBins = []
                    for (var bIdx = 0; bIdx < binCount; bIdx++) hourBins.push(0)
                    var appMap = {}
                    
                    // Parse ignore filter
                    var blacklistStr = plasmoid.configuration.blacklist.toLowerCase();
                    var blacklistArr = blacklistStr.split(",").map(function(s) {
                        return s.trim();
                    }).filter(Boolean);
                    
                    for (var i = 0; i < resultEvents.length; i++) {
                        var ev = resultEvents[i]
                        var dur = ev.duration
                        var app = ev.data.app || "Unknown"
                        var appLower = app.toLowerCase();
                        
                        // Check exclusions
                        var isBlacklisted = false;
                        for (var b = 0; b < blacklistArr.length; b++) {
                            if (appLower.indexOf(blacklistArr[b]) !== -1) {
                                isBlacklisted = true;
                                break;
                            }
                        }
                        if (isBlacklisted) continue;
                        
                        totalSecs += dur
                        
                        if (appMap[app] === undefined) appMap[app] = 0
                        appMap[app] += dur
                        
                        var evDate = new Date(ev.timestamp)
                        var hr = evDate.getHours()
                        var mappedHr = (hr >= startHour) ? (hr - startHour) : (hr + 24 - startHour)
                        if (mappedHr >= 0 && mappedHr < 24) {
                            var binIndex = Math.floor(mappedHr / step)
                            if (binIndex >= 0 && binIndex < binCount) {
                                hourBins[binIndex] += dur
                            }
                        }
                    }
                    
                    root.totalTimeStr = formatDuration(totalSecs)
                    root.hourlyData = hourBins
                    
                    var m = 1
                    for (var h = 0; h < binCount; h++) if (hourBins[h] > m) m = hourBins[h]
                    root.maxHourlyTime = m
                    
                    var sortable = []
                    for (var a in appMap) sortable.push([a, appMap[a]])
                    sortable.sort(function(a, b) { return b[1] - a[1] })
                    
                    if (sortable.length > 0) {
                        root.maxAppDuration = sortable[0][1];
                    } else {
                        root.maxAppDuration = 1;
                    }
                    
                    appsModel.clear()
                    var maxApps = Math.min(plasmoid.configuration.maxAppsShown, sortable.length)
                    var appListForCache = [];
                    
                    for (var k = 0; k < maxApps; k++) {
                        var appName = sortable[k][0];
                        var appDur = sortable[k][1];
                        var icon = mapIcon(appName);
                        var durationStr = formatDuration(appDur);
                        var pct = totalSecs > 0 ? Math.round((appDur / totalSecs) * 100) : 0;
                        var pctStr = pct + "%";
                        
                        appsModel.append({
                            "name": appName,
                            "durationStr": durationStr,
                            "percentageStr": pctStr,
                            "iconName": icon,
                            "rawDuration": appDur
                        });
                        
                        if (root.dayOffset < 0) {
                            appListForCache.push({
                                "name": appName,
                                "durationStr": durationStr,
                                "percentageStr": pctStr,
                                "iconName": icon,
                                "rawDuration": appDur
                            });
                        }
                    }
                    
                    if (root.dayOffset < 0) {
                        root.dataCache[root.dayOffset] = {
                            "totalTimeStr": root.totalTimeStr,
                            "hourlyData": root.hourlyData,
                            "maxHourlyTime": root.maxHourlyTime,
                            "maxAppDuration": root.maxAppDuration,
                            "apps": appListForCache
                        };
                    }
                    
                    root.triggerUpdate += 1
                } else {
                    // Server Offline / Unreachable
                    root.isServerOffline = true;
                    root.totalTimeStr = "Offline";
                    var offlineBins = [];
                    var offlineStep = root.hourStep;
                    var offlineBinCount = Math.ceil(24 / offlineStep);
                    for (var oIdx = 0; oIdx < offlineBinCount; oIdx++) offlineBins.push(0);
                    root.hourlyData = offlineBins;
                    root.maxHourlyTime = 1;
                    appsModel.clear();
                    root.triggerUpdate += 1;
                }
            }
        }
        xhr.send(JSON.stringify(payload))
    }
    
    compactRepresentation: MouseArea {
        id: compactRoot
        
        onClicked: root.expanded = !root.expanded
        
        RowLayout {
            anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing
            
            Kirigami.Icon {
                source: "view-time-schedule"
                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                isMask: true
            }
            
            PlasmaComponents.Label {
                text: root.totalTimeStr
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize + plasmoid.configuration.fontSizeModifier
                font.family: root.customFontFamily
                visible: compactRoot.width > (Kirigami.Units.iconSizes.small * 2.5)
                elide: Text.ElideRight
            }
        }
    }
    
    fullRepresentation: Item {
        id: fullRep
        
        Layout.minimumWidth: 320
        Layout.minimumHeight: 280
        Layout.preferredWidth: 400
        Layout.preferredHeight: 340
        
        property bool isLandscape: width >= 480 && width > height * 1.1
        
        // Background card placed as sibling so opacity doesn't affect child layout text/icons
        Rectangle {
            anchors.fill: parent
            color: plasmoid.configuration.backgroundColor
            radius: plasmoid.configuration.borderRadius
            border.color: plasmoid.configuration.borderColor
            border.width: plasmoid.configuration.borderWidth
            opacity: plasmoid.configuration.backgroundOpacity
            z: -1
        }
        
        // Offline Warning Overlay
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12
            visible: root.isServerOffline
            
            Item { Layout.fillHeight: true }
            
            Kirigami.Icon {
                source: "network-disconnect"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                color: "#FF453A"
                isMask: true
            }
            
            Text {
                text: "ActivityWatch Offline"
                color: "white"
                font.family: root.customFontFamily
                font.pixelSize: 16
                font.weight: Font.Bold
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: "Make sure aw-server is running at http://localhost:5600"
                color: "#8E8E93"
                font.family: root.customFontFamily
                font.pixelSize: 11
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: parent.width * 0.8
                Layout.alignment: Qt.AlignHCenter
                wrapMode: Text.Wrap
            }
            
            Item { Layout.preferredHeight: 8 }
            
            // Retry Button
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 32
                Layout.preferredWidth: 100
                radius: 16
                color: mouseAreaRetryOffline.containsMouse ? "#3A3A3C" : "#2C2C2E"
                
                Text {
                    anchors.centerIn: parent
                    text: "Retry"
                    color: "white"
                    font.family: root.customFontFamily
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                }
                
                MouseArea {
                    id: mouseAreaRetryOffline
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.dataCache = {};
                        root.fetchData();
                    }
                }
            }
            
            Item { Layout.fillHeight: true }
        }
        
        // Vertical Layout (Portrait)
        ColumnLayout {
            id: portraitLayout
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14
            visible: !fullRep.isLandscape && !root.isServerOffline
            
            // Header Row
            RowLayout {
                Layout.fillWidth: true
                visible: plasmoid.configuration.showHeader
                
                Text {
                    text: root.totalTimeStr
                    color: "white"
                    font.family: root.customFontFamily
                    // Dynamically scale font size based on layout width to prevent clipping
                    font.pixelSize: Math.min(32, Math.max(16, portraitLayout.width * 0.08)) + plasmoid.configuration.fontSizeModifier
                    font.weight: Font.DemiBold
                }
                
                Item { Layout.fillWidth: true }
                
                // Nav Buttons
                Rectangle {
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: navRow.implicitWidth + 24
                    radius: 16
                    color: "#2C2C2E"
                    
                    RowLayout {
                        id: navRow
                        anchors.centerIn: parent
                        spacing: 12
                        
                        // Left Arrow Character
                        Text {
                            text: "‹"
                            color: mouseAreaLeftArrow.containsMouse ? plasmoid.configuration.chartBarColorStart : "white"
                            font.family: root.customFontFamily
                            font.pixelSize: Math.max(10, 20 + plasmoid.configuration.fontSizeModifier)
                            font.weight: Font.Bold
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                            
                            Behavior on color { ColorAnimation { duration: 100 } }
                            
                            MouseArea {
                                id: mouseAreaLeftArrow
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.dayOffset--
                                anchors.margins: -8
                            }
                        }
                        
                        Text {
                            text: root.dateLabel
                            color: "#98989D"
                            font.family: root.customFontFamily
                            font.pixelSize: Math.max(9, 13 + plasmoid.configuration.fontSizeModifier)
                            font.weight: Font.DemiBold
                        }
                        
                        // Right Arrow Character
                        Text {
                            text: "›"
                            color: root.dayOffset < 0 ? (mouseAreaRightArrow.containsMouse ? plasmoid.configuration.chartBarColorStart : "white") : "#555555"
                            font.family: root.customFontFamily
                            font.pixelSize: Math.max(10, 20 + plasmoid.configuration.fontSizeModifier)
                            font.weight: Font.Bold
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                            
                            Behavior on color { ColorAnimation { duration: 100 } }
                            
                            MouseArea {
                                id: mouseAreaRightArrow
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: root.dayOffset < 0
                                cursorShape: root.dayOffset < 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: root.dayOffset++
                                anchors.margins: -8
                            }
                        }
                    }
                }
                
                // Refresh Button
                Rectangle {
                    id: refreshBtnPortrait
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: 32
                    radius: 16
                    color: mouseAreaRefreshPortrait.containsMouse ? "#3A3A3C" : "#2C2C2E"
                    Behavior on color { ColorAnimation { duration: 100 } }
                    
                    Kirigami.Icon {
                        source: "view-refresh"
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        color: "white"
                        isMask: true
                    }
                    
                    MouseArea {
                        id: mouseAreaRefreshPortrait
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.dataCache = {};
                            root.fetchData();
                        }
                    }
                }
            }
            
            // Chart Area (Scales dynamically based on parent height)
            Item {
                id: chartAreaPortrait
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(80, Math.min(220, portraitLayout.height * 0.35))
                Layout.fillHeight: true
                
                property real graphWidth: width - 40
                property real graphHeight: height - 20
                
                // Y-axis lines
                Repeater {
                    model: 3
                    Item {
                        width: chartAreaPortrait.width
                        height: 1
                        y: index * (chartAreaPortrait.graphHeight / 2)
                        
                        Rectangle {
                            width: chartAreaPortrait.graphWidth
                            height: 1
                            color: "#2C2C2E" // Soft grid color
                        }
                        
                        Text {
                            text: index === 0 ? formatDuration(root.maxHourlyTime) : (index === 1 ? formatDuration(root.maxHourlyTime / 2) : "0")
                            color: "#8E8E93"
                            font.family: root.customFontFamily
                            font.pixelSize: Math.max(8, 10 + plasmoid.configuration.fontSizeModifier)
                            font.weight: Font.DemiBold
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.top
                        }
                    }
                }
                
                // X-axis dashes
                Repeater {
                    model: 4
                    Item {
                        property int hourIndex: index * 6
                        x: (hourIndex / 24) * chartAreaPortrait.graphWidth
                        y: 0
                        width: 1
                        height: chartAreaPortrait.graphHeight
                        
                        Column {
                            spacing: 4
                            Repeater {
                                model: chartAreaPortrait.graphHeight / 6
                                Rectangle { width: 1; height: 2; color: "#2C2C2E" }
                            }
                        }
                        
                        Text {
                            text: {
                                var hr = (index * 6 + plasmoid.configuration.startHour) % 24;
                                return formatHourHelper(hr);
                            }
                            color: "#8E8E93"
                            font.family: root.customFontFamily
                            font.pixelSize: Math.max(8, 10 + plasmoid.configuration.fontSizeModifier)
                            font.weight: Font.DemiBold
                            anchors.top: parent.top
                            anchors.topMargin: chartAreaPortrait.graphHeight + 6
                            anchors.left: parent.left
                            anchors.leftMargin: 2
                        }
                    }
                }
                
                // Bars & Hover
                Repeater {
                    model: root.hourlyData.length
                    Item {
                        x: (index / root.hourlyData.length) * chartAreaPortrait.graphWidth
                        y: 0
                        width: chartAreaPortrait.graphWidth / root.hourlyData.length
                        height: chartAreaPortrait.graphHeight
                        
                        Rectangle {
                            id: visualBarPortrait
                            property real val: root.hourlyData[index] + (root.triggerUpdate * 0)
                            property real barHeight: val > 0 ? Math.max(2, (val / root.maxHourlyTime) * chartAreaPortrait.graphHeight) : 0
                            
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: Math.max(1, Math.min(plasmoid.configuration.barWidth, parent.width - 2))
                            height: barHeight
                            radius: plasmoid.configuration.barRadius
                            
                            // Configurable gradient colors
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: mouseAreaPortrait.containsMouse ? root.resolvedBarColorHoverStart : root.resolvedBarColorStart }
                                GradientStop { position: 1.0; color: mouseAreaPortrait.containsMouse ? root.resolvedBarColorHoverEnd : root.resolvedBarColorEnd }
                            }
                            
                            Behavior on height {
                                NumberAnimation { duration: 500; easing.type: Easing.OutQuint }
                            }
                        }
                        
                        MouseArea {
                            id: mouseAreaPortrait
                            anchors.fill: parent
                            hoverEnabled: true
                            onContainsMouseChanged: {
                                if (containsMouse) {
                                    tooltipBubblePortrait.hoveredIndex = index;
                                } else if (tooltipBubblePortrait.hoveredIndex === index) {
                                    tooltipBubblePortrait.hoveredIndex = -1;
                                }
                            }
                        }
                    }
                }
                
                // Declarative Tooltip Bubble
                Rectangle {
                    id: tooltipBubblePortrait
                    property int hoveredIndex: -1
                    visible: hoveredIndex !== -1
                    color: "#2C2C2E"
                    border.color: "#48484A"
                    border.width: 1
                    radius: 6
                    width: Math.max(80, tooltipTextPortrait.implicitWidth + 16)
                    height: tooltipTextPortrait.implicitHeight + 10
                    z: 100
                    
                    x: {
                        if (hoveredIndex === -1) return 0;
                        var colX = (hoveredIndex / 24) * chartAreaPortrait.graphWidth;
                        var colWidth = chartAreaPortrait.graphWidth / 24;
                        var targetX = colX + (colWidth - width) / 2;
                        return Math.max(0, Math.min(chartAreaPortrait.graphWidth - width, targetX));
                    }
                    
                    y: {
                        if (hoveredIndex === -1) return 0;
                        var val = root.hourlyData[hoveredIndex];
                        var barHeight = val > 0 ? Math.max(2, (val / root.maxHourlyTime) * chartAreaPortrait.graphHeight) : 0;
                        var barTop = chartAreaPortrait.graphHeight - barHeight;
                        return Math.max(0, barTop - height - 6);
                    }
                    
                    Text {
                        id: tooltipTextPortrait
                        text: tooltipBubblePortrait.hoveredIndex !== -1 ? (getHourLabel(tooltipBubblePortrait.hoveredIndex) + "\n" + formatDuration(root.hourlyData[tooltipBubblePortrait.hoveredIndex])) : ""
                        color: "white"
                        font.family: root.customFontFamily
                        font.pixelSize: Math.max(8, 11 + plasmoid.configuration.fontSizeModifier)
                        font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                        anchors.centerIn: parent
                    }
                }
            }
            
            Item { Layout.preferredHeight: 16 }
            
            // Apps Grid (Adaptive column count based on widget width)
            GridLayout {
                columns: portraitLayout.width >= 360 ? 2 : 1
                Layout.fillWidth: true
                Layout.fillHeight: true
                rowSpacing: 14
                columnSpacing: 24
                
                Repeater {
                    model: appsModel
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        
                        Rectangle {
                            anchors.fill: parent
                            color: itemHover.containsMouse ? "#2C2C2E" : "transparent"
                            radius: 8
                            Behavior on color { ColorAnimation { duration: 100 } }
                            
                            MouseArea {
                                id: itemHover
                                anchors.fill: parent
                                hoverEnabled: true
                            }
                        }
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 10
                            
                            Kirigami.Icon {
                                source: model.iconName
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                Layout.alignment: Qt.AlignVCenter
                            }
                            
                            ColumnLayout {
                                spacing: 4
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: model.name
                                        color: "white"
                                        font.family: root.customFontFamily
                                        font.pixelSize: Math.max(9, 13 + plasmoid.configuration.fontSizeModifier)
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        text: plasmoid.configuration.showPercentages ? (model.durationStr + " (" + model.percentageStr + ")") : model.durationStr
                                        color: "#98989D"
                                        font.family: root.customFontFamily
                                        font.pixelSize: Math.max(8, 11 + plasmoid.configuration.fontSizeModifier)
                                        font.weight: Font.Medium
                                    }
                                }
                                
                                // Progress bar showing relative share
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 3
                                    color: "#2C2C2E"
                                    radius: 1.5
                                    
                                    Rectangle {
                                        width: (root.maxAppDuration > 0 && model.rawDuration !== undefined) ? (model.rawDuration / root.maxAppDuration) * parent.width : 0
                                        height: parent.height
                                        radius: 1.5
                                        gradient: Gradient {
                                            orientation: Gradient.Horizontal
                                            GradientStop { position: 0.0; color: root.resolvedBarColorStart }
                                            GradientStop { position: 1.0; color: root.resolvedBarColorEnd }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Horizontal Layout (Landscape)
        RowLayout {
            id: landscapeLayout
            anchors.fill: parent
            anchors.margins: 20
            spacing: 24
            visible: fullRep.isLandscape && !root.isServerOffline
            
            // Left pane (Header & Chart)
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 14
                
                // Header Row
                RowLayout {
                    Layout.fillWidth: true
                    visible: plasmoid.configuration.showHeader
                    
                    Text {
                        text: root.totalTimeStr
                        color: "white"
                        font.family: root.customFontFamily
                        font.pixelSize: Math.min(32, Math.max(16, landscapeLayout.width * 0.05)) + plasmoid.configuration.fontSizeModifier
                        font.weight: Font.DemiBold
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    // Nav Buttons
                    Rectangle {
                        Layout.preferredHeight: 32
                        Layout.preferredWidth: navRowLandscape.implicitWidth + 24
                        radius: 16
                        color: "#2C2C2E"
                        
                        RowLayout {
                            id: navRowLandscape
                            anchors.centerIn: parent
                            spacing: 12
                            
                            // Left Arrow Character
                            Text {
                                text: "‹"
                                color: mouseAreaLeftArrowLandscape.containsMouse ? plasmoid.configuration.chartBarColorStart : "white"
                                font.family: root.customFontFamily
                                font.pixelSize: Math.max(10, 20 + plasmoid.configuration.fontSizeModifier)
                                font.weight: Font.Bold
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                
                                Behavior on color { ColorAnimation { duration: 100 } }
                                
                                MouseArea {
                                    id: mouseAreaLeftArrowLandscape
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.dayOffset--
                                    anchors.margins: -8
                                }
                            }
                            
                            Text {
                                text: root.dateLabel
                                color: "#98989D"
                                font.family: root.customFontFamily
                                font.pixelSize: Math.max(9, 13 + plasmoid.configuration.fontSizeModifier)
                                font.weight: Font.DemiBold
                            }
                            
                            // Right Arrow Character
                            Text {
                                text: "›"
                                color: root.dayOffset < 0 ? (mouseAreaRightArrowLandscape.containsMouse ? plasmoid.configuration.chartBarColorStart : "white") : "#555555"
                                font.family: root.customFontFamily
                                font.pixelSize: Math.max(10, 20 + plasmoid.configuration.fontSizeModifier)
                                font.weight: Font.Bold
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                
                                Behavior on color { ColorAnimation { duration: 100 } }
                                
                                MouseArea {
                                    id: mouseAreaRightArrowLandscape
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: root.dayOffset < 0
                                    cursorShape: root.dayOffset < 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: root.dayOffset++
                                    anchors.margins: -8
                                }
                            }
                        }
                    }
                    
                    // Refresh Button
                    Rectangle {
                        id: refreshBtnLandscape
                        Layout.preferredHeight: 32
                        Layout.preferredWidth: 32
                        radius: 16
                        color: mouseAreaRefreshLandscape.containsMouse ? "#3A3A3C" : "#2C2C2E"
                        Behavior on color { ColorAnimation { duration: 100 } }
                        
                        Kirigami.Icon {
                            source: "view-refresh"
                            anchors.centerIn: parent
                            width: 16
                            height: 16
                            color: "white"
                            isMask: true
                        }
                        
                        MouseArea {
                            id: mouseAreaRefreshLandscape
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.dataCache = {};
                                root.fetchData();
                            }
                        }
                    }
                }
                
                // Chart Area
                Item {
                    id: chartAreaLandscape
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    property real graphWidth: width - 40
                    property real graphHeight: height - 20
                    
                    // Y-axis lines
                    Repeater {
                        model: 3
                        Item {
                            width: chartAreaLandscape.width
                            height: 1
                            y: index * (chartAreaLandscape.graphHeight / 2)
                            
                            Rectangle {
                                width: chartAreaLandscape.graphWidth
                                height: 1
                                color: "#2C2C2E"
                            }
                            
                            Text {
                                text: index === 0 ? formatDuration(root.maxHourlyTime) : (index === 1 ? formatDuration(root.maxHourlyTime / 2) : "0")
                                color: "#8E8E93"
                                font.family: root.customFontFamily
                                font.pixelSize: Math.max(8, 10 + plasmoid.configuration.fontSizeModifier)
                                font.weight: Font.DemiBold
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.top
                            }
                        }
                    }
                    
                    // X-axis lines
                    Repeater {
                        model: 4
                        Item {
                            property int hourIndex: index * 6
                            x: (hourIndex / 24) * chartAreaLandscape.graphWidth
                            y: 0
                            width: 1
                            height: chartAreaLandscape.graphHeight
                            
                            Column {
                                spacing: 4
                                Repeater {
                                    model: chartAreaLandscape.graphHeight / 6
                                    Rectangle { width: 1; height: 2; color: "#2C2C2E" }
                                }
                            }
                            
                            Text {
                                text: {
                                    var hr = (index * 6 + plasmoid.configuration.startHour) % 24;
                                    return formatHourHelper(hr);
                                }
                                color: "#8E8E93"
                                font.family: root.customFontFamily
                                font.pixelSize: Math.max(8, 10 + plasmoid.configuration.fontSizeModifier)
                                font.weight: Font.DemiBold
                                anchors.top: parent.top
                                anchors.topMargin: chartAreaLandscape.graphHeight + 6
                                anchors.left: parent.left
                                anchors.leftMargin: 2
                            }
                        }
                    }
                    
                    // Bars & Hover
                    Repeater {
                        model: root.hourlyData.length
                        Item {
                            x: (index / root.hourlyData.length) * chartAreaLandscape.graphWidth
                            y: 0
                            width: chartAreaLandscape.graphWidth / root.hourlyData.length
                            height: chartAreaLandscape.graphHeight
                            
                            Rectangle {
                                id: visualBarLandscape
                                property real val: root.hourlyData[index] + (root.triggerUpdate * 0)
                                property real barHeight: val > 0 ? Math.max(2, (val / root.maxHourlyTime) * chartAreaLandscape.graphHeight) : 0
                                
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: Math.max(1, Math.min(plasmoid.configuration.barWidth, parent.width - 2))
                                height: barHeight
                                radius: plasmoid.configuration.barRadius
                                
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: mouseAreaLandscape.containsMouse ? root.resolvedBarColorHoverStart : root.resolvedBarColorStart }
                                    GradientStop { position: 1.0; color: mouseAreaLandscape.containsMouse ? root.resolvedBarColorHoverEnd : root.resolvedBarColorEnd }
                                }
                                
                                Behavior on height {
                                    NumberAnimation { duration: 500; easing.type: Easing.OutQuint }
                                }
                            }
                            
                            MouseArea {
                                id: mouseAreaLandscape
                                anchors.fill: parent
                                hoverEnabled: true
                                onContainsMouseChanged: {
                                    if (containsMouse) {
                                        tooltipBubbleLandscape.hoveredIndex = index;
                                    } else if (tooltipBubbleLandscape.hoveredIndex === index) {
                                        tooltipBubbleLandscape.hoveredIndex = -1;
                                    }
                                }
                            }
                        }
                    }
                    
                    // Declarative Tooltip Bubble
                    Rectangle {
                        id: tooltipBubbleLandscape
                        property int hoveredIndex: -1
                        visible: hoveredIndex !== -1
                        color: "#2C2C2E"
                        border.color: "#48484A"
                        border.width: 1
                        radius: 6
                        width: Math.max(80, tooltipTextLandscape.implicitWidth + 16)
                        height: tooltipTextLandscape.implicitHeight + 10
                        z: 100
                        
                        x: {
                            if (hoveredIndex === -1) return 0;
                            var colX = (hoveredIndex / 24) * chartAreaLandscape.graphWidth;
                            var colWidth = chartAreaLandscape.graphWidth / 24;
                            var targetX = colX + (colWidth - width) / 2;
                            return Math.max(0, Math.min(chartAreaLandscape.graphWidth - width, targetX));
                        }
                        
                        y: {
                            if (hoveredIndex === -1) return 0;
                            var val = root.hourlyData[hoveredIndex];
                            var barHeight = val > 0 ? Math.max(2, (val / root.maxHourlyTime) * chartAreaLandscape.graphHeight) : 0;
                            var barTop = chartAreaLandscape.graphHeight - barHeight;
                            return Math.max(0, barTop - height - 6);
                        }
                        
                        Text {
                            id: tooltipTextLandscape
                            text: tooltipBubbleLandscape.hoveredIndex !== -1 ? (getHourLabel(tooltipBubbleLandscape.hoveredIndex) + "\n" + formatDuration(root.hourlyData[tooltipBubbleLandscape.hoveredIndex])) : ""
                            color: "white"
                            font.family: root.customFontFamily
                            font.pixelSize: Math.max(8, 11 + plasmoid.configuration.fontSizeModifier)
                            font.weight: Font.Medium
                            horizontalAlignment: Text.AlignHCenter
                            anchors.centerIn: parent
                        }
                    }
                }
            }
            
            // Right pane (Apps List - scales dynamically with widget width)
            ColumnLayout {
                Layout.preferredWidth: Math.max(150, Math.min(300, landscapeLayout.width * 0.35))
                Layout.fillHeight: true
                spacing: 10
                
                Text {
                    text: "Top Apps"
                    color: "#98989D"
                    font.family: root.customFontFamily
                    font.pixelSize: Math.max(9, 13 + plasmoid.configuration.fontSizeModifier)
                    font.weight: Font.DemiBold
                    Layout.fillWidth: true
                }
                
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: appsModel
                    spacing: 8
                    delegate: Item {
                        width: ListView.view.width
                        height: 44
                        
                        Rectangle {
                            anchors.fill: parent
                            color: itemHoverLandscape.containsMouse ? "#2C2C2E" : "transparent"
                            radius: 8
                            Behavior on color { ColorAnimation { duration: 100 } }
                            
                            MouseArea {
                                id: itemHoverLandscape
                                anchors.fill: parent
                                hoverEnabled: true
                            }
                        }
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 10
                            
                            Kirigami.Icon {
                                source: model.iconName
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                Layout.alignment: Qt.AlignVCenter
                            }
                            
                            ColumnLayout {
                                spacing: 4
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: model.name
                                        color: "white"
                                        font.family: root.customFontFamily
                                        font.pixelSize: Math.max(9, 13 + plasmoid.configuration.fontSizeModifier)
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        text: plasmoid.configuration.showPercentages ? (model.durationStr + " (" + model.percentageStr + ")") : model.durationStr
                                        color: "#98989D"
                                        font.family: root.customFontFamily
                                        font.pixelSize: Math.max(8, 11 + plasmoid.configuration.fontSizeModifier)
                                        font.weight: Font.Medium
                                    }
                                }
                                
                                // Progress bar showing relative share
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 3
                                    color: "#2C2C2E"
                                    radius: 1.5
                                    
                                    Rectangle {
                                        width: (root.maxAppDuration > 0 && model.rawDuration !== undefined) ? (model.rawDuration / root.maxAppDuration) * parent.width : 0
                                        height: parent.height
                                        radius: 1.5
                                        gradient: Gradient {
                                            orientation: Gradient.Horizontal
                                            GradientStop { position: 0.0; color: root.resolvedBarColorStart }
                                            GradientStop { position: 1.0; color: root.resolvedBarColorEnd }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}