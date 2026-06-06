import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root
    
    property int triggerUpdate: 0
    property string totalTimeStr: "..."
    property int dayOffset: 0
    property string dateLabel: "Today"
    
    onDayOffsetChanged: {
        updateDateLabel();
        fetchData();
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
    
    property var hourlyData: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
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

    function mapIcon(appName) {
        appName = appName.toLowerCase()
        if (appName.indexOf("chrome") !== -1) return "google-chrome"
        if (appName.indexOf("code") !== -1) return "visual-studio-code"
        if (appName.indexOf("kitty") !== -1 || appName.indexOf("term") !== -1) return "utilities-terminal"
        if (appName.indexOf("brave") !== -1) return "brave-browser"
        if (appName.indexOf("firefox") !== -1) return "firefox"
        if (appName.indexOf("dolphin") !== -1 || appName.indexOf("finder") !== -1) return "system-file-manager"
        if (appName.indexOf("whatsapp") !== -1) return "whatsapp"
        if (appName.indexOf("system") !== -1) return "preferences-system"
        return "application-x-executable"
    }

    function fetchData() {
        var xhr = new XMLHttpRequest()
        xhr.open("POST", "http://127.0.0.1:5600/api/0/query/")
        xhr.setRequestHeader("Content-Type", "application/json")
        
        var now = new Date()
        // Offset by 6 hours so 00:00 - 05:59 falls into the previous "logical" day
        var logicalNow = new Date(now.getTime() - 6 * 3600 * 1000)
        var targetDate = new Date(logicalNow.getFullYear(), logicalNow.getMonth(), logicalNow.getDate() + root.dayOffset)
        
        // Start of the logical day is 6:00 AM
        var startOfDay = new Date(targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate(), 6, 0, 0, 0)
        // End of the logical day is 5:59:59.999 AM of the next calendar day
        var endOfDay = new Date(targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate() + 1, 5, 59, 59, 999)
        
        var query = "afk = query_bucket(find_bucket(\"aw-watcher-afk_\"));\n" +
                    "window = query_bucket(find_bucket(\"aw-watcher-window_\"));\n" +
                    "not_afk = filter_keyvals(afk, \"status\", [\"not-afk\"]);\n" +
                    "active_window = filter_period_intersect(window, not_afk);\n" +
                    "RETURN = active_window;"
                    
        var payload = { "query": [query], "timeperiods": [startOfDay.toISOString() + "/" + endOfDay.toISOString()] }
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                var response = JSON.parse(xhr.responseText)
                var resultEvents = response[0]
                if (resultEvents && resultEvents.length > 0 && Array.isArray(resultEvents[0])) resultEvents = resultEvents[0]
                if (!resultEvents || !resultEvents.length) resultEvents = []
                
                var totalSecs = 0
                var hourBins = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
                var appMap = {}
                
                for (var i = 0; i < resultEvents.length; i++) {
                    var ev = resultEvents[i]
                    var dur = ev.duration
                    var app = ev.data.app || "Unknown"
                    
                    totalSecs += dur
                    
                    if (appMap[app] === undefined) appMap[app] = 0
                    appMap[app] += dur
                    
                    var evDate = new Date(ev.timestamp)
                    var hr = evDate.getHours()
                    var mappedHr = (hr >= 6) ? (hr - 6) : (hr + 18)
                    if (mappedHr >= 0 && mappedHr < 24) hourBins[mappedHr] += dur
                }
                
                root.totalTimeStr = formatDuration(totalSecs)
                root.hourlyData = hourBins
                root.triggerUpdate += 1
                
                var m = 1
                for (var h = 0; h < 24; h++) if (hourBins[h] > m) m = hourBins[h]
                root.maxHourlyTime = m
                
                // Sort apps
                var sortable = []
                for (var a in appMap) sortable.push([a, appMap[a]])
                sortable.sort(function(a, b) { return b[1] - a[1] })
                
                appsModel.clear()
                var maxApps = Math.min(6, sortable.length)
                for (var k = 0; k < maxApps; k++) {
                    appsModel.append({
                        "name": sortable[k][0],
                        "durationStr": formatDuration(sortable[k][1]),
                        "iconName": mapIcon(sortable[k][0])
                    })
                }
            }
        }
        xhr.send(JSON.stringify(payload))
    }
    
    fullRepresentation: Item {
        Layout.minimumWidth: 320
        Layout.minimumHeight: 340
        
        Rectangle {
            anchors.fill: parent
            color: "#1C1C1E" // Standard macOS dark grey
            radius: 20
            border.color: "#303030"
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14
                
                // Top Header (26m)
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: root.totalTimeStr
                        color: "white"
                        font.pixelSize: 32
                        font.weight: Font.DemiBold
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Rectangle {
                        Layout.preferredHeight: 32
                        Layout.preferredWidth: navRow.implicitWidth + 24
                        radius: 16
                        color: "#2C2C2E"
                        
                        RowLayout {
                            id: navRow
                            anchors.centerIn: parent
                            spacing: 12
                            
                            Kirigami.Icon {
                                source: "go-previous"
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                color: "white"
                                isMask: true
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.dayOffset--
                                    anchors.margins: -8 // Fatter hit box
                                }
                            }
                            
                            Text {
                                text: root.dateLabel
                                color: "#98989D"
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                            }
                            
                            Kirigami.Icon {
                                source: "go-next"
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                color: root.dayOffset < 0 ? "white" : "#555555"
                                isMask: true
                                
                                MouseArea {
                                    anchors.fill: parent
                                    enabled: root.dayOffset < 0
                                    cursorShape: root.dayOffset < 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: root.dayOffset++
                                    anchors.margins: -8
                                }
                            }
                        }
                    }
                    
                    Rectangle {
                        Layout.preferredHeight: 32
                        Layout.preferredWidth: 32
                        radius: 16
                        color: "#2C2C2E"
                        
                        Kirigami.Icon {
                            source: "view-refresh"
                            anchors.centerIn: parent
                            width: 16
                            height: 16
                            color: "white"
                            isMask: true
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.fetchData()
                        }
                    }
                }
                
                // Chart Area
                Item {
                    id: chartArea
                    Layout.fillWidth: true
                    Layout.preferredHeight: 140 // Slightly taller for labels
                    
                    property real graphWidth: width - 40 // Space for right Y-axis labels
                    property real graphHeight: height - 20 // Space for bottom X-axis labels
                    
                    // Horizontal Grid lines & Y-axis Labels
                    Repeater {
                        model: 3
                        Item {
                            width: chartArea.width
                            height: 1
                            y: index * (chartArea.graphHeight / 2)
                            
                            // Horizontal Line
                            Rectangle {
                                width: chartArea.graphWidth
                                height: 1
                                color: "#38383A"
                            }
                            
                            // Y-axis Label
                            Text {
                                text: index === 0 ? formatDuration(root.maxHourlyTime) : (index === 1 ? formatDuration(root.maxHourlyTime / 2) : "0")
                                color: "#98989D"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.top
                            }
                        }
                    }
                    
                    // Vertical Grid Lines & X-axis Labels (at hours 0, 6, 12, 18)
                    Repeater {
                        model: 4
                        Item {
                            property int hourIndex: index * 6
                            x: (hourIndex / 24) * chartArea.graphWidth
                            y: 0
                            width: 1
                            height: chartArea.height
                            
                            // Vertical dashed/dim line
                            Column {
                                spacing: 4
                                Repeater {
                                    model: chartArea.graphHeight / 6
                                    Rectangle { width: 1; height: 2; color: "#38383A" }
                                }
                            }
                            
                            // X-axis Label
                            Text {
                                text: ["6 AM", "12 PM", "6 PM", "12 AM"][index]
                                color: "#98989D"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                anchors.top: parent.top
                                anchors.topMargin: chartArea.graphHeight + 6
                                anchors.left: parent.left
                                anchors.leftMargin: 2
                            }
                        }
                    }
                    
                    // Chart bars
                    Repeater {
                        model: 24
                        Rectangle {
                            property real val: root.hourlyData[index] + (root.triggerUpdate * 0)
                            property real barHeight: val > 0 ? Math.max(2, (val / root.maxHourlyTime) * chartArea.graphHeight) : 0
                            
                            x: (index / 24) * chartArea.graphWidth
                            y: chartArea.graphHeight - height // bound correctly with animated height
                            width: Math.max(1, (chartArea.graphWidth / 24) - 2)
                            height: barHeight
                            color: "#0A84FF"
                            radius: 3
                            
                            Behavior on height {
                                NumberAnimation { duration: 500; easing.type: Easing.OutQuint }
                            }
                        }
                    }
                }
                
                Item { Layout.preferredHeight: 16 } // Spacer
                
                // Apps Grid
                GridLayout {
                    columns: 2
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    rowSpacing: 14
                    columnSpacing: 24
                    
                    Repeater {
                        model: appsModel
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            
                            RowLayout {
                                anchors.fill: parent
                                spacing: 10
                                
                                Kirigami.Icon {
                                    source: model.iconName
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                }
                                
                                ColumnLayout {
                                    spacing: 2
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    
                                    Text { 
                                        text: model.name
                                        color: "white"
                                        font.pixelSize: 13
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true 
                                    }
                                    Text { 
                                        text: model.durationStr
                                        color: "#98989D"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
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