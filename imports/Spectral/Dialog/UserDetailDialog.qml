import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import Spectral.Component 2.0
import Spectral.Effect 2.0
import Spectral.Setting 0.1

Dialog {
    property var room
    property var user

    property string displayName: user.displayName
    property string avatarMediaId: user.avatarMediaId
    property string avatarUrl: user.avatarUrl

    anchors.centerIn: parent
    width: 360

    id: root

    modal: true

    contentItem: ColumnLayout {
        RowLayout {
            Layout.fillWidth: true

            spacing: 16

            Avatar {
                Layout.preferredWidth: 72
                Layout.preferredHeight: 72

                hint: displayName
                source: avatarMediaId

                RippleEffect {
                    anchors.fill: parent

                    circular: true

                    onPrimaryClicked: {
                        if (avatarMediaId) {
                            fullScreenImage.createObject(parent, {"filename": displayName, "localPath": room.urlToMxcUrl(avatarUrl)}).showFullScreen()
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true

                Label {
                    Layout.fillWidth: true

                    font.pixelSize: 18
                    font.bold: true

                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                    text: displayName
                    color: MPalette.foreground
                }

                Label {
                    Layout.fillWidth: true

                    text: "Online"
                    color: MPalette.lighter
                }
            }
        }

        MenuSeparator {
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true

            spacing: 8

            MaterialIcon {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                Layout.alignment: Qt.AlignTop

                icon: "\ue88f"
                color: MPalette.lighter
            }

            ColumnLayout {
                Layout.fillWidth: true

                Label {
                    Layout.fillWidth: true

                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                    text: user.id
                    color: MPalette.accent
                }

                Label {
                    Layout.fillWidth: true

                    wrapMode: Label.Wrap
                    text: "User ID"
                    color: MPalette.lighter
                }
            }
        }

        MenuSeparator {
            Layout.fillWidth: true
        }

        Control {
            Layout.fillWidth: true

            // No need to show this option when the direct chat with this person is already open imo
            visible: !room.isDirectChat();

            contentItem: RowLayout {
                MaterialIcon {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    Layout.alignment: Qt.AlignTop

                    icon: "\ue0c9"
                    color: MPalette.lighter
                }

                Label {
                    Layout.fillWidth: true

                    wrapMode: Label.Wrap
                    text: "Message this user"

                    color: MPalette.accent
                }
            }

            background: RippleEffect {
                // This will either emit the existing chat or create a new one and emit it
                onPrimaryClicked: {
                    spectralController.connection.requestDirectChat(user)
                }
            }

            // We then simply capture that and change the view
            Connections {
                target: spectralController.connection;
                onDirectChatAvailable: {
                    root.close()
                    console.log(directChat)
                    roomListForm.filter = 1
                    roomListForm.joinRoom(directChat)
                    }
            }
        }

        Control {
            Layout.fillWidth: true

            contentItem: RowLayout {
                MaterialIcon {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    Layout.alignment: Qt.AlignTop

                    icon: room.connection.isIgnored(user) ? "\ue7f5" : "\ue7f6"
                    color: MPalette.lighter
                }

                Label {
                    Layout.fillWidth: true

                    wrapMode: Label.Wrap
                    text: room.connection.isIgnored(user) ? "Unignore this user" : "Ignore this user"

                    color: MPalette.accent
                }
            }

            background: RippleEffect {
                onPrimaryClicked: {
                    root.close()
                    room.connection.isIgnored(user) ? room.connection.removeFromIgnoredUsers(user) : room.connection.addToIgnoredUsers(user)
                }
            }
        }

        Control {
            Layout.fillWidth: true

            contentItem: RowLayout {
                MaterialIcon {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    Layout.alignment: Qt.AlignTop

                    icon: "\ue5d9"
                    color: MPalette.lighter
                }

                Label {
                    Layout.fillWidth: true

                    wrapMode: Label.Wrap
                    text: "Kick this user"

                    color: MPalette.accent
                }
            }

            background: RippleEffect {
                onPrimaryClicked: room.kickMember(user.id)
            }
        }
    }

    Component {
        id: fullScreenImage

        FullScreenImage {}
    }

    onClosed: destroy()
}

