import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects

ShellRoot {
    // TOP BAR
    Variants {
        model: Quickshell.screens

        delegate: PanelWindow {
            required property var modelData
            screen: modelData

            WlrLayershell.layer: WlrLayer.Top

            anchors {
                top: true
                left: true
                right: true
            }
            height: 30
            color: "black"

            Rectangle {
                anchors.fill: parent
                height: 30
                color: "black"

                Text {
                    anchors.centerIn: parent
                    text: "System Bar"
                    color: "white"
                }
            }
        }
    }

    // LEFT BAR
    Variants {
        model: Quickshell.screens

        delegate: PanelWindow {
            required property var modelData
            screen: modelData

            WlrLayershell.layer: WlrLayer.Top

            // Position the bar at the top
            anchors {
                left: true
                top: true
                bottom: true
            }
            width: 10
            color: "black"
        }
    }

    // RIGHT BAR
    Variants {
        model: Quickshell.screens

        delegate: PanelWindow {
            required property var modelData
            screen: modelData

            WlrLayershell.layer: WlrLayer.Top

            // Position the bar at the top
            anchors {
                right: true
                top: true
                bottom: true
            }
            width: 10
            color: "black"
        }
    }

    // BOTTOM BAR
    Variants {
        model: Quickshell.screens

        delegate: PanelWindow {
            required property var modelData
            screen: modelData

            WlrLayershell.layer: WlrLayer.Top

            anchors {
                right: true
                left: true
                bottom: true
            }
            height: 10
            color: "black"
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: PanelWindow {
            id: backgroundContainer
            required property var modelData
            screen: modelData

            WlrLayershell.layer: WlrLayer.Background

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            // Outer frame
            Rectangle {
                anchors.fill: parent
                color: "black"
                z: -1
            }

            Item {
                id: imageContainer
                anchors.fill: parent
                layer.enabled: true

                Image {
                    id: contentSource
                    anchors.fill: parent
                    source: "grand_teton.jpg"
                    visible: false
                }

                MultiEffect {
                    id: effect
                    anchors.fill: parent
                    source: contentSource

                    maskEnabled: true
                    maskSource: ShaderEffectSource {
                        sourceItem: Rectangle {
                            width: imageContainer.width
                            height: imageContainer.height
                            radius: 15
                        }
                    }
                }

                Item {
                    anchors.fill: parent
                    clip: true

                    MultiEffect {
                        anchors.fill: shadowSource
                        source: shadowSource
                        shadowEnabled: true
                        shadowColor: "black"
                        shadowBlur: 1.0
                    }

                    Rectangle {
                        id: shadowSource
                        anchors.fill: parent
                        anchors.margins: -50
                        color: "transparent"
                        border.color: "black"
                        border.width: 50
                        radius: 60
                        visible: false
                    }
                }
            }
        }
    }
}
