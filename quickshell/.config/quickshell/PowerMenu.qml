import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts

PanelWindow {
  id: powerProfiles
  width: 225
  implicitHeight: 181
  anchors.top: true
  anchors.right: true
  margins.top: 17
  margins.right: 17
  color: "transparent"
  Behavior on implicitHeight {
    NumberAnimation { duration: 200; easing.type: Easing.InOutCubic }
  }

  property bool menuOpen: false
  visible: powerProfiles.menuOpen
  property bool idleInhibited: Globals.idleInhibited

  IdleInhibitor {
    id: idleInhibit
    window: PanelWindow {
      implicitWidth: 0
      implicitHeight: 0
      color: "transparent"
      anchors {
        right: true
        bottom: true
      }
      mask: Region {
        item: null
      }
    }
    enabled: idleInhibited
  }
  Timer {
    id: hideTimer
    interval: 1500
    repeat: false
    onTriggered: {
      if (!batteryMenuMouseArea.containsMouse) {
        powerProfiles.menuOpen = false;
      }
    }
  }
  MouseArea {
    id: batteryMenuMouseArea
    anchors.fill: parent
    hoverEnabled: true
    onEntered: {
      hideTimer.stop()
    }
    onExited: {
      hideTimer.restart()
    }
  }
  ListModel {
    id: menuModel
    Component.onCompleted: updateModel()
  }
  function updateModel() {
    menuModel.clear()
    menuModel.append({
      title: "Power Saving",
      icon: "󰌪",
      profile: "powersave",
      action: "set-profile",
      isActive: curPowerProfile === "powersave"
    })
    menuModel.append({
      title: "Balanced",
      icon: "󰾅",
      profile: "balanced",
      action: "set-profile",
      isActive: curPowerProfile === "balanced"
    })
    menuModel.append({
      title: "Performance",
      icon: "",
      profile: "throughput-performance",
      action: "set-profile",
      isActive: curPowerProfile === "throughput-performance"
    })
    menuModel.append({
      title: "Idle Inhibitor",
      icon: "󰈈",
      action: "idle-inhibit",
      isActive: idleInhibited
    })
    if (UPower.displayDevice.timeToEmpty !== 0 || UPower.displayDevice.timeToFull !== 0) {
      menuModel.append({
        title: UPowerDeviceState.toString(UPower.displayDevice.state).includes("Discharging") ? "Time to empty: " + new Date(UPower.displayDevice.timeToEmpty * 1000).toISOString().slice(11, 16) : "Time to full: " + new Date(UPower.displayDevice.timeToFull * 1000).toISOString().slice(11, 16),
        icon: "󰦖"
      })
    }
    menuModel.append({
      title: "Power: " + UPower.displayDevice.changeRate.toFixed(2) + "W",
      icon: "󰠠",
      command: ["sh", "-c", "kitty battop"],
      action: "run-command"
    })
  }
  onMenuOpenChanged: {
    if (menuOpen) {
      updateModel()
    }
  }
  Rectangle {
    anchors.fill: parent
    radius: 10
    color: Qt.alpha(root.base, 0.5)
    border.width: 1
    border.color: Qt.alpha(root.overlay0, 0.8)

    Column {
      anchors.fill: parent
      spacing: 0

      ListView {
        id: listView
        width: parent.width
        implicitHeight: parent.height
        model: menuModel
        clip: true

        delegate: Rectangle {
          required property string title
          required property string icon
          required property string action
          required property string profile
          required property bool isActive
          required property list<string> command

          radius: 10
          width: listView.width
          implicitHeight: 30
          color: listMouseArea.containsMouse ? Qt.alpha(root.surface1, 0.5) : "transparent"
          Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            spacing: 15
            Text {
              text: isActive ? "✓" : icon
              width: 8
              color: isActive ? root.teal : root.sapphire
              font.pixelSize: root.fontSize
              font.bold: true
            }
            Text {
              text: title
              color: isActive ? root.teal : root.text
              font.pixelSize: root.fontSize
            }
          }
          MouseArea {
            id: listMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
              if (action === "set-profile") {
                commandRunner.command = ["tuned-adm", "profile", profile]
                commandRunner.running = true
                powerProfiles.menuOpen = false
              } else if (action === "idle-inhibit") {
                idleInhibited = !idleInhibited
                powerProfiles.menuOpen = false
              } else if (action === "run-command") {
                commandRunner.command = command
                commandRunner.running = true
                powerProfiles.menuOpen = false
              }
            }
          }
        }
      }
    }
  }
}
