import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
  anchors.top: true
  anchors.left: true
  anchors.right: true
  anchors.bottom: true
  margins.top: 16
  id: musicPanel
  color: "transparent"

  property bool menuOpen: false
  visible: musicPanel.menuOpen

  IpcHandler {
    target: "musicCenter"

    function setVisible(vis: bool): void { musicPanel.menuOpen = vis; }
    function getVisible(): bool { return musicPanel.menuOpen}
    function invertVisible(): void { musicPanel.menuOpen = !musicPanel.menuOpen }
  }

  Timer {
    id: hideTimer
    interval: 1500
    repeat: false
    onTriggered: {
      if (!musicMenuMouseArea.containsMouse) {
        musicPanel.menuOpen = false;
      }
    }
  }
  MouseArea {
    id: musicMenuMouseArea
    anchors.fill: parent
    hoverEnabled: true
    onClicked: {
      musicPanel.menuOpen = false;
    }
    onEntered: {
      hideTimer.restart()
    }
    onExited: {
      hideTimer.stop()
    }
  }

  onMenuOpenChanged: {
    if (menuOpen) {
    }
  }
  function formatTime(seconds) {
    if (isNaN(seconds) || seconds < 0) return "0:00";
    let mins = Math.floor(seconds / 60);
    let secs = Math.floor(seconds % 60);
    let formattedSecs = secs < 10 ? "0" + secs : secs;
    return mins + ":" + formattedSecs;
  }
  Rectangle {
    width: 650
    implicitHeight: 250
    x: parent.width / 2 - width / 2
    radius: 10
    color: Qt.alpha(root.base, 0.5)
    border.width: 1
    border.color: Qt.alpha(root.overlay0, 0.8)
    Behavior on implicitHeight {
      NumberAnimation { duration: 200; easing.type: Easing.InOutCubic }
    }

    Image {
      id: cover
      height: parent.height - 40
      width: parent.height - 40
      x: 10
      y: 10
      source: "file://" + musicCoverFile
      cache: false
      mipmap: true
    }
    Text {
      x: cover.width + cover.x*2
      y: 20
      width: parent.width - (cover.width + cover.x*2) - 10
      elide: Text.ElideRight
      text: musicTitle
      color: root.text
      font { family: root.fontFamily; pixelSize: root.fontSize * 1.5; bold: true }
    }
    Text {
      x: cover.width + cover.x*2
      y: 35 + root.fontSize * 1.5
      width: parent.width - (cover.width + cover.x*2) - extraInfo.width - 20
      elide: Text.ElideRight
      text: ` ${musicArtist} • 󰀥 ${musicAlbum}`
      color: root.subtext0
      font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
    }
    Text {
      id: extraInfo
      x: parent.width - width - 10
      y: 35
      text: `󰐵 ${musicBitrate}kbps\n󰐑 ${musicQueuePos}/${musicQueueLen} • ${musicRepeat ? "󰑖" : "󰑗"}`
      horizontalAlignment: Text.AlignRight
      color: root.overlay0
      font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
    }
    Text {
      x: parent.width - width - 10
      y: parent.height - height - 30
      text: `${formatTime(musicElapsed)}/${formatTime(musicDuration)}`
      horizontalAlignment: Text.AlignRight
      color: root.subtext1
      font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
    }
    RowLayout {
      x: cover.width + 20
      y: parent.height - height - 30
      spacing: 5
      Rectangle {
        implicitWidth: root.fontSize * 3 + 10
        implicitHeight: root.fontSize * 3 + 10
        radius: 10
        color: skipBackMouseArea.containsMouse ? Qt.alpha(root.surface1, 0.5) : "transparent"
        Text {
          text: "󰒮"
          anchors.centerIn: parent
          color: skipBackMouseArea.containsMouse ? root.sapphire : root.text
          font { family: root.fontFamily; pixelSize: root.fontSize * 3; bold: true }
          scale: skipBackMouseArea.pressed ? 0.85 : 1
          Behavior on scale {
            NumberAnimation { duration: 200 }
          }
        }
        MouseArea {
          id: skipBackMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onPressed: (event) => {
            commandRunner.command = ["rmpc", "prev"]
            commandRunner.running = true
          }
        }
      }
      Rectangle {
        implicitWidth: root.fontSize * 3 + 10
        implicitHeight: root.fontSize * 3 + 10
        radius: 10
        color: seekBackMouseArea.containsMouse ? Qt.alpha(root.surface1, 0.5) : "transparent"
        Text {
          text: "󰒫"
          anchors.centerIn: parent
          color: seekBackMouseArea.containsMouse ? root.sapphire : root.text
          font { family: root.fontFamily; pixelSize: root.fontSize * 3; bold: true }
          scale: seekBackMouseArea.pressed ? 0.85 : 1
          Behavior on scale {
            NumberAnimation { duration: 200 }
          }
        }
        MouseArea {
          id: seekBackMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onPressed: (event) => {
            commandRunner.command = ["rmpc", "seek", "-10"]
            commandRunner.running = true
          }
        }
      }
      Rectangle {
        implicitWidth: root.fontSize * 3 + 10
        implicitHeight: root.fontSize * 3 + 10
        radius: 10
        color: playMouseArea.containsMouse ? Qt.alpha(root.surface1, 0.5) : "transparent"
        Text {
          text: musicState == "Pause" ? "" : musicState == "Play" ? "" : ""
          anchors.centerIn: parent
          color: playMouseArea.containsMouse ? root.sapphire : root.text
          font { family: root.fontFamily; pixelSize: root.fontSize * 3; bold: true }
          scale: playMouseArea.pressed ? 0.85 : 1
          Behavior on scale {
            NumberAnimation { duration: 200 }
          }
        }
        MouseArea {
          id: playMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onPressed: (event) => {
            commandRunner.command = ["rmpc", "togglepause"]
            commandRunner.running = true
          }
        }
      }
      Rectangle {
        implicitWidth: root.fontSize * 3 + 10
        implicitHeight: root.fontSize * 3 + 10
        radius: 10
        color: seekForwardMouseArea.containsMouse ? Qt.alpha(root.surface1, 0.5) : "transparent"
        Text {
          text: "󰒬"
          anchors.centerIn: parent
          color: seekForwardMouseArea.containsMouse ? root.sapphire : root.text
          font { family: root.fontFamily; pixelSize: root.fontSize * 3; bold: true }
          scale: seekForwardMouseArea.pressed ? 0.85 : 1
          Behavior on scale {
            NumberAnimation { duration: 200 }
          }
        }
        MouseArea {
          id: seekForwardMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onPressed: (event) => {
            commandRunner.command = ["rmpc", "seek", "+10"]
            commandRunner.running = true
          }
        }
      }
      Rectangle {
        implicitWidth: root.fontSize * 3 + 10
        implicitHeight: root.fontSize * 3 + 10
        radius: 10
        color: skipForwardMouseArea.containsMouse ? Qt.alpha(root.surface1, 0.5) : "transparent"
        Text {
          text: "󰒭"
          anchors.centerIn: parent
          color: skipForwardMouseArea.containsMouse ? root.sapphire : root.text
          font { family: root.fontFamily; pixelSize: root.fontSize * 3; bold: true }
          scale: skipForwardMouseArea.pressed ? 0.85 : 1
          Behavior on scale {
            NumberAnimation { duration: 200 }
          }
        }
        MouseArea {
          id: skipForwardMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onPressed: (event) => {
            commandRunner.command = ["rmpc", "next"]
            commandRunner.running = true
          }
        }
      }
    }
    Rectangle {
      id: progressBar
      width: parent.width - 1
      height: 20
      y: parent.height - 21
      color: Qt.alpha(root.crust, 0.2)
      radius: 10

      Rectangle {
        width: progressBar.width * (musicElapsed / musicDuration)
        height: parent.height
        color: root.sapphire
        radius: 10
        Behavior on width {
          NumberAnimation {
            duration: 1000
            easing.type: Easing.Linear
          }
        }
      }
    }
  }
}
