import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Services.UPower
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import QtQuick.Controls
import QtQuick
import QtQuick.Layouts

Variants {
  model: Quickshell.screens
  PanelWindow {
    id: topBar
    required property var modelData
    screen: modelData
    aboveWindows: false

    anchors.top: true
    anchors.left: true
    anchors.right: true
    margins.top: 10
    margins.left: 15
    margins.right: 15
    implicitHeight: 36

    property bool trayVisible: false
    Timer {
      id: trayHideTimer
      interval: 1500
      repeat: false
      onTriggered: {
        trayVisible = false
      }
    }
    surfaceFormat.opaque: false
    color: "transparent"
    Rectangle {
      id: panelBackground
      anchors.fill: parent
      radius: 10
      color: Qt.alpha(root.base, 0.5)
      border.width: 1
      border.color: Qt.alpha(root.overlay0, 0.8)
    }

    RowLayout {
      anchors.fill: parent
      anchors.margins: 0
      spacing: 0

      Item { Layout.preferredWidth: 4 }

      Rectangle {
        id: systemMenuButton
        implicitWidth: 34
        implicitHeight: 34
        color: mouseArea.containsMouse ? Qt.alpha(root.surface1, 0.5) : "transparent"
        scale: mouseArea.pressed ? 0.9 : 1
        Behavior on scale {
          NumberAnimation { duration: 200 }
        }
        Image {
          id: icon
          anchors.fill: parent
          source: "megastar.svg"
          mipmap: true
          scale: mouseArea.pressed ? 0.9 : 1
          Behavior on scale {
            NumberAnimation { duration: 200 }
          }
        }
        MouseArea {
          id: mouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            commandRunner.command = ["python", "-m", "fabric", "execute", "Widgets", "toggle_system_menu()", "-j"]
            commandRunner.running = true
          }
        }
      }
      Item { Layout.preferredWidth: 5 }
      RowLayout {
        spacing: 0
        Repeater {
          model: Hyprland.workspaces
          delegate: Rectangle {
            id: wsButton
            visible: modelData.id > 0
            required property var modelData
            property int ws: modelData.id
            property bool isFocused: modelData.focused
            property bool isUrgent: modelData.urgent
            implicitWidth: textItem.implicitWidth + 10
            implicitHeight: 34
            color: wsMouseArea.containsMouse ? Qt.alpha(root.surface1, 0.5) : "transparent"
            scale: mouseArea.pressed ? 0.9 : 1
            Behavior on scale {
              NumberAnimation { duration: 200 }
            }
            Text {
              id: textItem
              anchors.centerIn: parent
              text: isUrgent ? "" : (isFocused ? "" : (ws ? "" : ""))
              color: isUrgent ? root.red : (wsMouseArea.containsMouse ? root.sapphire : (isFocused ? root.rosewater : root.text))
              Behavior on color {
                ColorAnimation { duration: 200 } // duration in milliseconds
              }
              font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
            }
            MouseArea {
              id: wsMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + ws + " })")
            }
          }
        }
      }

      Item { Layout.fillWidth: true }
      RowLayout {
        spacing: 8
        Text {
          text: " " + temprature + "°"
          color: root.subtext0
          font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
        }
        Rectangle { width: 1; height:16; color: root.surface1 }
        Text {
          text: " " + cpuUsage + "%"
          color: root.subtext0
          font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
        }
        Rectangle { width: 1; height:16; color: root.surface1 }
        Text {
          text: " " + memUsage + "%"
          color: root.subtext0
          font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
        }
        Rectangle { width: 1; height:16; color: root.surface1 }
        Text {
          text: "󰤛 " + gpuUsage + "%"
          color: root.subtext0
          font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
        }
      }
      Item { Layout.preferredWidth: 10 }
      Rectangle { width: 1; height:16; color: root.surface1 }
      Item { Layout.preferredWidth: 5;visible: topBar.trayVisible }
      RowLayout {
        visible: topBar.trayVisible
        id: systemTray
        spacing: 2
        PanelWindow {
          id: trayWindow
          implicitWidth: 0
          implicitHeight: 0
          color: "transparent"
          mask: Region {
            item: null
          }
        }
        Repeater {
          id: trayItems
          model: SystemTray.items
          delegate: Rectangle {
            id: trayItem
            required property var modelData
            implicitWidth: 22
            implicitHeight: 34
            color: trayItemMouseArea.containsMouse ? Qt.alpha(root.surface1, 0.5) : "transparent"
            Image {
              id: trayIcon
              anchors.centerIn: parent
              height: 18
              width: 18
              source: modelData.icon
              mipmap: true
              scale: trayItemMouseArea.pressed ? 0.85 : 1
              Behavior on scale {
                NumberAnimation { duration: 200 }
              }
            }
            MouseArea {
              id: trayItemMouseArea
              anchors.fill: parent
              hoverEnabled: true
              acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
              cursorShape: Qt.PointingHandCursor
              onPressed: (event) => {
                var pos = trayItem.mapToItem(null, 0, 0)
                var menuY = pos.y + trayItem.height
                if (event.button === Qt.MiddleButton) {
                  modelData.secondaryActive()
                } else if (event.button === Qt.LeftButton && modelData.onlyMenu) {
                  modelData.display(topBar, pos.x, menuY)
                } else if (event.button === Qt.LeftButton) {
                  modelData.activate()
                } else if (event.button === Qt.RightButton) {
                  modelData.display(topBar, pos.x, menuY)
                }
              }
              onEntered: {
                topBar.trayHideTimer.stop()
              }
              onExited: {
                topBar.trayHideTimer.restart()
              }
            }
          }
        }
      }
      Rectangle {
        id: trayOpenButton
        implicitWidth: 30
        implicitHeight: 34
        color: trayOpenMouseArea.containsMouse ? Qt.alpha(root.surface1, 0.5) : "transparent"
        scale: trayOpenMouseArea.pressed ? 0.9 : 1
        Behavior on scale {
          NumberAnimation { duration: 200 }
        }
        Text {
          anchors.centerIn: parent
          text: topBar.trayVisible ? "" : ""
          color: root.rosewater
          font { family: root.fontFamily; pixelSize: 20; bold: true }
          scale: topBar.trayVisible ? 0.8 : 1.0
          Behavior on scale {
            NumberAnimation { duration: 200 }
          }
        }
        MouseArea {
          id: trayOpenMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            topBar.trayVisible = !topBar.trayVisible
          }
          onEntered: {
            topBar.trayHideTimer.stop()
          }
          onExited: {
            topBar.trayHideTimer.restart()
          }
        }
      }
      Rectangle { width: 1; height:16; color: root.surface1 }
      Rectangle {
        id: audioButton
        implicitWidth: 70
        implicitHeight: 34
        color: audioMouseArea.containsMouse ? Qt.alpha(root.surface1, 0.5) : "transparent"
        scale: audioMouseArea.pressed ? 0.9 : 1
        Behavior on scale {
          NumberAnimation { duration: 200 }
        }
        property PwNode sink: Pipewire.defaultAudioSink
        property PwNode source: Pipewire.defaultAudioSource
        PwObjectTracker {
          objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
        }
        property string defaultAudio: Pipewire.defaultAudioSink.nickname
        property real volume: Math.round(sink?.audio.volume*100) ?? 0
        Text {
          anchors.centerIn: parent
          text: `${audioButton.volume >= 66 ? "" : (audioButton.volume >= 33 ? "" : "")} ${audioButton.volume}%`
          color: root.blue
          font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
        }
        MouseArea {
          id: audioMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            commandRunner.command = ["pavucontrol", "--tab", "3"]
              commandRunner.running = true
          }
          property real scrollAmount: 0
          onWheel: (wheel) => {
            let isTrackpad = wheel.pixelDelta.y !== 0 || wheel.pixelDelta.x !== 0
            let normalizedDelta = isTrackpad ? -wheel.angleDelta.y : wheel.angleDelta.y
            scrollAmount += normalizedDelta
            let threshold = isTrackpad ? 50 : 1
            if (Math.abs(scrollAmount) >= threshold) {
              if (scrollAmount > 0) {
                let newVolume = audioButton.sink.audio.volume+0.01
                if (newVolume > 1) {
                  newVolume = 1
                }
                audioButton.sink.audio.volume = newVolume
              } else if (scrollAmount < 0){
                let newVolume = audioButton.sink.audio.volume-0.01
                if (newVolume < 0) {
                  newVolume = 0
                }
                audioButton.sink.audio.volume = newVolume
              }
              scrollAmount = 0
            }
          }
        }
      }
      Rectangle { width: 1; height:16; color: root.surface1 }
      Rectangle {
        id: displayButton
        implicitWidth: 70
        implicitHeight: 34
        color: displayMouseArea.containsMouse ? Qt.alpha(root.surface1, 0.5) : "transparent"
        scale: displayMouseArea.pressed ? 0.9 : 1
        Behavior on scale {
          NumberAnimation { duration: 200 }
        }
        Text {
          anchors.centerIn: parent
          text: `${root.brightness >= 75 ? "󰃠": (root.brightness >= 50 ? "󰃝" : (root.brightness >= 25 ? "󰃟" : "󰃞"))} ${root.brightness}%`
          color: noNoti === 0 || dnd ? root.sky : root.green
          font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
        }
        MouseArea {
          id: displayMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            /* commandRunner.command = ["swaync-client", "-t", "-sw"]
              commandRunner.running = true */
          }
          property real scrollAmount: 0
          onWheel: (wheel) => {
            let isTrackpad = wheel.pixelDelta.y !== 0 || wheel.pixelDelta.x !== 0
            let normalizedDelta = isTrackpad ? -wheel.angleDelta.y : wheel.angleDelta.y
            scrollAmount += normalizedDelta
            let threshold = isTrackpad ? 2 : 1
            if (Math.abs(scrollAmount) >= threshold) {
              if (scrollAmount > 0) {
                commandRunner.command = ["brightnessctl", "s", "+2%"]
                commandRunner.running = true
              } else if (scrollAmount < 0){
                commandRunner.command = ["brightnessctl", "s", "2%-"]
                commandRunner.running = true
              }
              scrollAmount = 0
            }
          }
        }
      }
      Rectangle { width: 1; height:16; color: root.surface1 }
      Rectangle {
        id: bluetoothButton
        implicitWidth: 30
        implicitHeight: 34
        color: bluetoothMouseArea.containsMouse ? Qt.alpha(root.surface1, 0.5) : "transparent"
        scale: bluetoothMouseArea.pressed ? 0.9 : 1
        Behavior on scale {
          NumberAnimation { duration: 200 }
        }
        property bool btEnabled: Bluetooth.defaultAdapter.enabled
        property int btNoConnected: Bluetooth.defaultAdapter.devices.values.filter((device)=>device.connected===true).length
        Text {
          anchors.centerIn: parent
          text: bluetoothButton.btNoConnected > 0 ? "󰂱" : (bluetoothButton.btEnabled ? "󰂯" : "󰂲")
          color: bluetoothButton.btEnabled ? root.sky : root.peach
          font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
        }
        MouseArea {
          id: bluetoothMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            commandRunner.command = ["blueman-manager"]
            commandRunner.running = true
          }
        }
        ToolTip.visible: bluetoothMouseArea.containsMouse
        ToolTip.text: bluetoothButton.btNoConnected === 1 ? "1 Device connected" : bluetoothButton.btNoConnected + "Notifications"
        ToolTip.delay: 3000
      }
      Rectangle {
        id: networkButton
        implicitWidth: 30
        implicitHeight: 34
        color: netMouseArea.containsMouse ? Qt.alpha(root.surface1, 0.5) : "transparent"
        scale: netMouseArea.pressed ? 0.9 : 1

        property bool wifiEnabled: Networking.wifiEnabled
        property bool wifiHardwareEnabled: Networking.wifiHardwareEnabled
        property bool internetAvailable: Networking.connectivity === NetworkConnectivity.Full
        property bool captivePortal: Networking.connectivity === NetworkConnectivity.Portal
        property bool limitedConnectivity: Networking.connectivity === NetworkConnectivity.Limited
        property bool connectivityUnknown: Networking.connectivity !== NetworkConnectivity.Unknown
        property bool notConnected: Networking.connectivity !== NetworkConnectivity.None
        property Network connectedWifi: Networking.devices.values.filter((device)=>device.type===DeviceType.Wifi)[0].networks.values.filter((network)=>network.connected===true)[0]
        property int signalStrength: connectedWifi.signalStrength*100
        property string ssid: connectedWifi.name
        property string wifiSecurity: WifiSecurityType.toString(connectedWifi.security)
        property bool ethernetPluggedIn: WiredDevice.hasLink
        property int ethernetSpeed: WiredDevice.linkSpeed
        readonly property list<string> securityList: ["wpa3", "wpa2", "wpapsk", "wpa2psk", "sae", "wpaeap", "wpa2eap", "wpa3suiteb192", "staticwep", "dynamicwep", "leap"]
        property string netIcon: switch (true) {
          case (wifiEnabled && internetAvailable && signalStrength >= 80 && securityList.includes(wifiSecurity.toLowerCase())):  return "󰤪"
          case (wifiEnabled && internetAvailable && signalStrength >= 60 && securityList.includes(wifiSecurity.toLowerCase())):  return "󰤧"
          case (wifiEnabled && internetAvailable && signalStrength >= 40 && securityList.includes(wifiSecurity.toLowerCase())):  return "󰤤"
          case (wifiEnabled && internetAvailable && signalStrength >= 20 && securityList.includes(wifiSecurity.toLowerCase())):  return "󰤡"
          case (wifiEnabled && internetAvailable && signalStrength >= 0 && securityList.includes(wifiSecurity.toLowerCase())):  return "󰤬"
          case (wifiEnabled && (limitedConnectivity || captivePortal) && signalStrength >= 80):  return "󰤩"
          case (wifiEnabled && (limitedConnectivity || captivePortal) && signalStrength >= 60):  return "󰤦"
          case (wifiEnabled && (limitedConnectivity || captivePortal) && signalStrength >= 40):  return "󰤣"
          case (wifiEnabled && (limitedConnectivity || captivePortal) && signalStrength >= 20):  return "󰤠"
          case (wifiEnabled && (limitedConnectivity || captivePortal) && signalStrength >= 0):  return "󰤫"
          case (wifiEnabled && internetAvailable && signalStrength >= 80):  return "󰤨"
          case (wifiEnabled && internetAvailable && signalStrength >= 60):  return "󰤥"
          case (wifiEnabled && internetAvailable && signalStrength >= 40):  return "󰤢"
          case (wifiEnabled && internetAvailable && signalStrength >= 20):  return "󰤟"
          case (wifiEnabled && internetAvailable && signalStrength >= 0):  return "󰤯"
          case (wifiEnabled && (notConnected || Networking.connectivity === 1)):  return "󰤮"
          case ((!wifiEnabled || !wifiHardwareEnabled) && internetAvailable):  return ""
          case ((!wifiEnabled || !wifiHardwareEnabled) && (notConnected || Networking.connectivity === 1)):  return "󰲛"
          default: return ""
        }
        Behavior on scale {
          NumberAnimation { duration: 200 }
        }
        Text {
          anchors.centerIn: parent
          text: networkButton.netIcon
          color: root.yellow
          font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
        }
        MouseArea {
          id: netMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            commandRunner.command = ["kitty", "--class", "wifitui", "wifitui"]
            commandRunner.running = true
          }
        }
        ToolTip.visible: netMouseArea.containsMouse
        ToolTip.text: `Connected to: ${ssid} | Security: ${wifiSecurity} | Signal strength: ${signalStrength}%`
        ToolTip.delay: 2000
      }
      Rectangle { width: 1; height:16; color: root.surface1 }
      Rectangle {
        id: clockButton
        implicitWidth: clock.width + 20
        implicitHeight: 34
        color: "transparent"
        Text {
          id: clock
          color: root.mauve
          font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
          text: Qt.formatDateTime(new Date(), "dd/MM HH:mm")
          anchors.centerIn: parent
          Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clock.text = Qt.formatDateTime(new Date(), "dd/MM HH:mm")
          }
        }
      }
      Rectangle { width: 1; height:16; color: root.surface1 }
      Rectangle {
        id: batteryButton
        implicitWidth: 70
        implicitHeight: 34
        color: Math.round(UPower.displayDevice.percentage * 100) <= 20 ? Qt.alpha(root.red, 0.3) : (batteryMouseArea.containsMouse ? Qt.alpha(root.surface1, 0.5) : "transparent")
        scale: batteryMouseArea.pressed ? 0.9 : 1
        Behavior on scale {
          NumberAnimation { duration: 200 }
        }
        Text {
          property int batteryLevel: Math.round(UPower.displayDevice.percentage * 100)
          property string battState: UPowerDeviceState.toString(UPower.displayDevice.state)
          property string battIcon: switch (true) {
            case (batteryLevel >= 70 && battState === "Charging"): return "󰂅"
            case (batteryLevel >= 55 && battState === "Charging"): return "󰢞"
            case (batteryLevel >= 40 && battState === "Charging"): return "󰢝"
            case (batteryLevel >= 25 && battState === "Charging"): return "󰂆"
            case (batteryLevel >= 0 && battState === "Charging"): return "󰢜"
            case (batteryLevel >= 70): return "󰁹"
            case (batteryLevel >= 55): return "󰂀"
            case (batteryLevel >= 40): return "󰁾"
            case (batteryLevel >= 25): return "󰁻"
            case (batteryLevel >= 0): return "󰂎"
            default: return ""
          }
          property string stateIcon: switch (battState) {
            case "Discharging": return battIcon
            case "Pending Discharge": return battIcon
            case "Pending Charge": return "󱟢" // "󱈏"
            case "Charging": return battIcon
            case "Fully charged": return "󱟢"
            default: return battIcon
          }
          id: batteryText
          anchors.centerIn: parent
          text: `${stateIcon} ${batteryLevel}%`
          color: battState.includes("Discharging") ? (batteryLevel <= 15 ? root.red : (batteryLevel <= 25 ? root.peach : root.lavender)) : root.teal
          font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
        }
        MouseArea {
          id: batteryMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            powerMenu.menuOpen = !powerMenu.menuOpen
          }
        }
      }
      Rectangle { width: 1; height:16; color: root.surface1 }
      Rectangle {
        id: notificationButton
        implicitWidth: 30
        implicitHeight: 34
        color: notiMouseArea.containsMouse ? Qt.alpha(root.surface1, 0.5) : "transparent"
        scale: notiMouseArea.pressed ? 0.9 : 1
        Behavior on scale {
          NumberAnimation { duration: 200 }
        }
        Text {
          anchors.centerIn: parent
          text: dnd ? (noNoti === 0 ? "󰪓" : "󰂠") : (noNoti === 0 ? "󰂜" : "󱅫")
          color: noNoti === 0 || dnd ? root.sky : root.green
          font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
        }
        MouseArea {
          id: notiMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            commandRunner.command = ["swaync-client", "-t", "-sw"]
            commandRunner.running = true
          }
        }
        ToolTip.visible: noNoti !== 0 ? notiMouseArea.containsMouse : false
        ToolTip.text: noNoti === 1 ? "1 Notification" : noNoti + "Notifications"
        ToolTip.delay: 1000
      }

      Item { Layout.preferredWidth: 10 }
    }
  }
}
