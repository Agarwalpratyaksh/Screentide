import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import QtQuick.Dialogs

ScrollView {
    id: root
    
    implicitWidth: 420
    implicitHeight: 550
    
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: ScrollBar.AsNeeded

    // Configuration property bindings (cfg_ prefix maps to main.xml entries)
    property alias cfg_borderRadius: borderRadiusSlider.value
    property alias cfg_backgroundColor: backgroundColorField.text
    property alias cfg_backgroundOpacity: backgroundOpacitySlider.value
    property alias cfg_borderColor: borderColorField.text
    property alias cfg_borderWidth: borderWidthSlider.value
    property alias cfg_startHour: startHourSlider.value
    property alias cfg_chartBarColorStart: chartBarColorStartField.text
    property alias cfg_chartBarColorEnd: chartBarColorEndField.text
    property alias cfg_chartBarColorHoverStart: chartBarColorHoverStartField.text
    property alias cfg_chartBarColorHoverEnd: chartBarColorHoverEndField.text
    property alias cfg_showHeader: showHeaderCheckBox.checked
    property alias cfg_barRadius: barRadiusSlider.value
    property alias cfg_maxAppsShown: maxAppsShownSlider.value
    property alias cfg_fontSizeModifier: fontSizeModifierSlider.value
    property alias cfg_fontFamily: fontFamilyField.text
    property alias cfg_showPercentages: showPercentagesCheckBox.checked
    property alias cfg_barWidth: barWidthSlider.value
    property alias cfg_blacklist: blacklistField.text
    property alias cfg_useSolidColor: useSolidColorCheckBox.checked
    property alias cfg_useSystemTheme: useSystemThemeCheckBox.checked
    property alias cfg_hourStepIndex: hourStepComboBox.currentIndex

    ColorDialog {
        id: colorDialog
        title: "Select Color"
        property var targetField: null
        onAccepted: {
            if (targetField) {
                targetField.text = selectedColor.toString();
            }
        }
    }

    Kirigami.FormLayout {
        // Set width to available viewport width; height expands naturally to enable scrolling
        width: root.availableWidth
        
        // --- SECTION: Background Styling ---
        
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Background & Borders")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Border Radius:")
            Layout.fillWidth: true
            
            Slider {
                id: borderRadiusSlider
                Layout.fillWidth: true
                from: 0
                to: 40
                stepSize: 1
            }
            SpinBox {
                id: borderRadiusSpinBox
                from: 0
                to: 40
                value: borderRadiusSlider.value
                onValueModified: borderRadiusSlider.value = value
            }
        }
        
        RowLayout {
            Kirigami.FormData.label: i18n("Background Color (Hex):")
            Layout.fillWidth: true
            
            TextField {
                id: backgroundColorField
                Layout.fillWidth: true
                placeholderText: "#1C1C1E"
            }
            Rectangle {
                width: 32
                height: 32
                radius: 4
                color: {
                    var c = backgroundColorField.text.trim();
                    return (c.indexOf("#") === 0 && (c.length === 7 || c.length === 9)) ? c : "#1C1C1E";
                }
                border.color: "#48484A"
                border.width: 1
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        colorDialog.targetField = backgroundColorField;
                        colorDialog.selectedColor = parent.color;
                        colorDialog.open();
                    }
                }
            }
        }
        
        RowLayout {
            Kirigami.FormData.label: i18n("Background Opacity:")
            Layout.fillWidth: true
            
            Slider {
                id: backgroundOpacitySlider
                Layout.fillWidth: true
                from: 0.0
                to: 1.0
                stepSize: 0.05
            }
            SpinBox {
                id: backgroundOpacitySpinBox
                from: 0
                to: 100
                stepSize: 5
                value: Math.round(backgroundOpacitySlider.value * 100)
                onValueModified: backgroundOpacitySlider.value = value / 100.0
                textFromValue: function(value, locale) { return value + "%"; }
                valueFromText: function(text, locale) { return parseInt(text.replace("%", "")); }
            }
        }
        
        RowLayout {
            Kirigami.FormData.label: i18n("Border Color (Hex):")
            Layout.fillWidth: true
            
            TextField {
                id: borderColorField
                Layout.fillWidth: true
                placeholderText: "#0DFFFFFF"
            }
            Rectangle {
                width: 32
                height: 32
                radius: 4
                color: {
                    var c = borderColorField.text.trim();
                    return (c.indexOf("#") === 0 && (c.length === 7 || c.length === 9)) ? c : "#0DFFFFFF";
                }
                border.color: "#48484A"
                border.width: 1
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        colorDialog.targetField = borderColorField;
                        colorDialog.selectedColor = parent.color;
                        colorDialog.open();
                    }
                }
            }
        }
        
        RowLayout {
            Kirigami.FormData.label: i18n("Border Width (px):")
            Layout.fillWidth: true
            
            Slider {
                id: borderWidthSlider
                Layout.fillWidth: true
                from: 0
                to: 10
                stepSize: 1
            }
            SpinBox {
                id: borderWidthSpinBox
                from: 0
                to: 10
                value: borderWidthSlider.value
                onValueModified: borderWidthSlider.value = value
            }
        }
        
        // --- SECTION: Layout & Sizing ---
        
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Layout & Sizing")
        }

        CheckBox {
            id: showHeaderCheckBox
            Kirigami.FormData.label: i18n("Show Title Header:")
        }

        CheckBox {
            id: showPercentagesCheckBox
            Kirigami.FormData.label: i18n("Show App Percentages:")
        }

        ComboBox {
            id: hourStepComboBox
            Kirigami.FormData.label: i18n("Chart Hour Grouping:")
            model: ["1 Hour (24 bars)", "2 Hours (12 bars)", "3 Hours (8 bars)", "4 Hours (6 bars)", "6 Hours (4 bars)"]
            Layout.fillWidth: true
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Max Apps Listed:")
            Layout.fillWidth: true
            
            Slider {
                id: maxAppsShownSlider
                Layout.fillWidth: true
                from: 3
                to: 15
                stepSize: 1
            }
            SpinBox {
                id: maxAppsShownSpinBox
                from: 3
                to: 15
                value: maxAppsShownSlider.value
                onValueModified: maxAppsShownSlider.value = value
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Chart Bar Width (px):")
            Layout.fillWidth: true
            
            Slider {
                id: barWidthSlider
                Layout.fillWidth: true
                from: 8
                to: 32
                stepSize: 1
            }
            SpinBox {
                id: barWidthSpinBox
                from: 8
                to: 32
                value: barWidthSlider.value
                onValueModified: barWidthSlider.value = value
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Chart Bar Radius (px):")
            Layout.fillWidth: true
            
            Slider {
                id: barRadiusSlider
                Layout.fillWidth: true
                from: 0
                to: 12
                stepSize: 1
            }
            SpinBox {
                id: barRadiusSpinBox
                from: 0
                to: 12
                value: barRadiusSlider.value
                onValueModified: barRadiusSlider.value = value
            }
        }
        
        // --- SECTION: Typography ---
        
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Typography")
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Font Size Modifier (pt):")
            Layout.fillWidth: true
            
            Slider {
                id: fontSizeModifierSlider
                Layout.fillWidth: true
                from: -4
                to: 10
                stepSize: 1
            }
            SpinBox {
                id: fontSizeModifierSpinBox
                from: -4
                to: 10
                value: fontSizeModifierSlider.value
                onValueModified: fontSizeModifierSlider.value = value
            }
        }

        TextField {
            id: fontFamilyField
            Kirigami.FormData.label: i18n("Font Family:")
            placeholderText: "e.g. JetBrains Mono, Inter"
            Layout.fillWidth: true
        }

        // --- SECTION: Exclusions & Filters ---
        
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Filters & Exclusions")
        }

        TextField {
            id: blacklistField
            Kirigami.FormData.label: i18n("Ignore Applications:")
            placeholderText: "e.g. krunner,lockscreen,kwin"
            Layout.fillWidth: true
        }

        // --- SECTION: Time Tracker Schedule ---
        
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Time Schedule")
        }
        
        RowLayout {
            Kirigami.FormData.label: i18n("Logical Day Start:")
            Layout.fillWidth: true
            
            Slider {
                id: startHourSlider
                Layout.fillWidth: true
                from: 0
                to: 23
                stepSize: 1
            }
            
            Label {
                text: {
                    var labels = ["12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM", "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM"];
                    var val = Math.floor(startHourSlider.value);
                    return (val >= 0 && val < 24) ? labels[val] : "";
                }
                font.bold: true
                Layout.preferredWidth: 60
                horizontalAlignment: Text.AlignRight
            }
        }
        
        // --- SECTION: Chart Theme Colors ---
        
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Chart Theme Colors")
        }

        CheckBox {
            id: useSystemThemeCheckBox
            Kirigami.FormData.label: i18n("Use System Accent Colors:")
        }

        CheckBox {
            id: useSolidColorCheckBox
            Kirigami.FormData.label: i18n("Use Solid Color (No Gradients):")
        }
        
        RowLayout {
            Kirigami.FormData.label: useSolidColorCheckBox.checked ? i18n("Bar Color:") : i18n("Bar Gradient Start:")
            Layout.fillWidth: true
            visible: !useSystemThemeCheckBox.checked
            
            TextField {
                id: chartBarColorStartField
                Layout.fillWidth: true
                placeholderText: "#00C6FF"
            }
            Rectangle {
                width: 32
                height: 32
                radius: 4
                color: {
                    var c = chartBarColorStartField.text.trim();
                    return (c.indexOf("#") === 0 && (c.length === 7 || c.length === 9)) ? c : "#00C6FF";
                }
                border.color: "#48484A"
                border.width: 1
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        colorDialog.targetField = chartBarColorStartField;
                        colorDialog.selectedColor = parent.color;
                        colorDialog.open();
                    }
                }
            }
        }
        
        RowLayout {
            Kirigami.FormData.label: i18n("Bar Gradient End:")
            Layout.fillWidth: true
            visible: !useSystemThemeCheckBox.checked && !useSolidColorCheckBox.checked
            
            TextField {
                id: chartBarColorEndField
                Layout.fillWidth: true
                placeholderText: "#0072FF"
            }
            Rectangle {
                width: 32
                height: 32
                radius: 4
                color: {
                    var c = chartBarColorEndField.text.trim();
                    return (c.indexOf("#") === 0 && (c.length === 7 || c.length === 9)) ? c : "#0072FF";
                }
                border.color: "#48484A"
                border.width: 1
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        colorDialog.targetField = chartBarColorEndField;
                        colorDialog.selectedColor = parent.color;
                        colorDialog.open();
                    }
                }
            }
        }
        
        RowLayout {
            Kirigami.FormData.label: useSolidColorCheckBox.checked ? i18n("Bar Hover Color:") : i18n("Bar Hover Start:")
            Layout.fillWidth: true
            visible: !useSystemThemeCheckBox.checked
            
            TextField {
                id: chartBarColorHoverStartField
                Layout.fillWidth: true
                placeholderText: "#60CFFF"
            }
            Rectangle {
                width: 32
                height: 32
                radius: 4
                color: {
                    var c = chartBarColorHoverStartField.text.trim();
                    return (c.indexOf("#") === 0 && (c.length === 7 || c.length === 9)) ? c : "#60CFFF";
                }
                border.color: "#48484A"
                border.width: 1
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        colorDialog.targetField = chartBarColorHoverStartField;
                        colorDialog.selectedColor = parent.color;
                        colorDialog.open();
                    }
                }
            }
        }
        
        RowLayout {
            Kirigami.FormData.label: i18n("Bar Hover End:")
            Layout.fillWidth: true
            visible: !useSystemThemeCheckBox.checked && !useSolidColorCheckBox.checked
            
            TextField {
                id: chartBarColorHoverEndField
                Layout.fillWidth: true
                placeholderText: "#2094FF"
            }
            Rectangle {
                width: 32
                height: 32
                radius: 4
                color: {
                    var c = chartBarColorHoverEndField.text.trim();
                    return (c.indexOf("#") === 0 && (c.length === 7 || c.length === 9)) ? c : "#2094FF";
                }
                border.color: "#48484A"
                border.width: 1
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        colorDialog.targetField = chartBarColorHoverEndField;
                        colorDialog.selectedColor = parent.color;
                        colorDialog.open();
                    }
                }
            }
        }

        // --- SECTION: System / Reset Actions ---
        
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Maintenance Actions")
        }

        Button {
            text: i18n("Reset to Default Settings")
            icon.name: "edit-clear-all"
            Layout.fillWidth: true
            
            onClicked: {
                borderRadiusSlider.value = 20;
                backgroundColorField.text = "#1C1C1E";
                backgroundOpacitySlider.value = 0.96;
                borderColorField.text = "#0DFFFFFF";
                borderWidthSlider.value = 1;
                startHourSlider.value = 6;
                chartBarColorStartField.text = "#00C6FF";
                chartBarColorEndField.text = "#0072FF";
                chartBarColorHoverStartField.text = "#60CFFF";
                chartBarColorHoverEndField.text = "#2094FF";
                showHeaderCheckBox.checked = true;
                barRadiusSlider.value = 4;
                maxAppsShownSlider.value = 5;
                fontSizeModifierSlider.value = 0;
                fontFamilyField.text = "";
                showPercentagesCheckBox.checked = true;
                barWidthSlider.value = 16;
                blacklistField.text = "krunner,lockscreen";
                useSolidColorCheckBox.checked = false;
                useSystemThemeCheckBox.checked = false;
                hourStepComboBox.currentIndex = 0;
            }
        }
    }
}
