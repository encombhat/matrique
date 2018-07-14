import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.2
import QtQml.Models 2.3
import Matrique 0.1
import SortFilterProxyModel 0.2

import "qrc:/qml/component"

Item {
    property alias listModel: roomListProxyModel.sourceModel
    property int currentIndex: roomListProxyModel.mapToSource(listView.currentIndex)
    readonly property bool mini: width <= 80 // Used as an indicator of whether the listform should be displayed as "Mini mode".

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Pane {
            z: 10
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            background: Rectangle {
                color: Qt.tint(Material.accent, "#20FFFFFF")
            }

            TextField {
                id: searchField
                width: parent.width
                height: 36
                leftPadding: mini ? 4 : 16
                topPadding: 0
                bottomPadding: 0
                anchors.verticalCenter: parent.verticalCenter

                background: Item {
                    Row {
                        anchors.fill: parent

                        MaterialIcon {
                            icon: "\ue8b6"
                            color: "white"

                            width: mini ? parent.width : parent.height
                            height: parent.height
                        }

                        Label {
                            height: parent.height
                            visible: !mini
                            text: "Search"
                            color: "white"
                            font.pointSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Rectangle {
                        width: searchField.activeFocus || searchField.text ? parent.width : 0
                        height: parent.height
                        color: "white"

                        Behavior on width {
                            PropertyAnimation { easing.type: Easing.InOutCubic; duration: 200 }
                        }
                    }
                }
            }
        }

        Pane {
            Layout.fillWidth: true
            Layout.fillHeight: true
            padding: 0

            background: Item {
                anchors.fill: parent
                Rectangle {
                    anchors.fill: parent
                    color: Material.theme == Material.Light ? "#eaeaea" : "#242424"
                }

                Label {
                    z: 10
                    text: mini ? "Empty" : "Here? No, not here."
                    anchors.centerIn: parent
                    visible: listView.count === 0
                }
            }

            SortFilterProxyModel {
                id: roomListProxyModel
                filters: RegExpFilter {
                    roleName: "name"
                    pattern: searchField.text
                    caseSensitivity: Qt.CaseInsensitive
                }
                proxyRoles: [
                    ExpressionRole { name: "isFavorite"; expression: category === "Favorites" },
                    ExpressionRole { name: "isLowPriority"; expression: category === "Low Priorities" }
                ]
                sorters: [
                    RoleSorter { roleName: "isFavorite"; sortOrder: Qt.DescendingOrder },
                    RoleSorter { roleName: "isLowPriority" },
                    StringSorter { roleName: "name" }
                ]
            }


            ListView {
                id: listView
                width: parent.width
                height: parent.height

                model: roomListProxyModel

                highlight: Rectangle {
                    color: Material.accent
                    opacity: 0.2
                }
                highlightMoveDuration: 250

                currentIndex: -1

                ScrollBar.vertical: ScrollBar { id: scrollBar }

                delegate: ItemDelegate {
                    width: parent.width
                    height: 80
                    onClicked: listView.currentIndex = index

                    ToolTip.visible: mini && hovered
                    ToolTip.text: name

                    contentItem:  RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16

                        ImageStatus {
                            Layout.preferredWidth: height
                            Layout.fillHeight: true

                            source: avatar ? "image://mxc/" + avatar : ""
                            displayText: name
                            opaqueBackground: true
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignHCenter

                            visible: parent.width > 80

                            Label {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                text: {
                                    if (name) {
                                        return name;
                                    }
                                    if (alias) {
                                        return alias;
                                    }
                                    return id
                                }
                                font.pointSize: 16
                                elide: Text.ElideRight
                                wrapMode: Text.NoWrap
                            }

                            Label {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                text: topic ? topic : "No topic yet."
                                elide: Text.ElideRight
                                wrapMode: Text.NoWrap
                            }
                        }
                    }
                }

                section.property: "category"
                section.criteria: ViewSection.FullString
                section.delegate: Label {
                    width: parent.width
                    height: 24
                    text: section
                    color: "grey"
                    leftPadding: 16
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    background: Rectangle { anchors.fill:parent; color: "#dbdbdb" }
                }
            }
        }
    }
}
