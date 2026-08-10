//@ pragma UseQApplication

import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root

  property color rosewater: "#f5e0dc"
  property color flamingo: "#f2cdcd"
  property color pink: "#f5c2e7"
  property color mauve: "#cba6f7"
  property color red: "#f38ba8"
  property color maroon: "#eba0ac"
  property color peach: "#fab387"
  property color yellow: "#f9e2af"
  property color green: "#a6e3a1"
  property color teal: "#94e2d5"
  property color sky: "#89dceb"
  property color sapphire: "#74c7ec"
  property color blue: "#89b4fa"
  property color lavender: "#b4befe"
  property color text: "#cdd6f4"
  property color subtext1: "#bac2de"
  property color subtext0: "#a6adc8"
  property color overlay2: "#9399b2"
  property color overlay1: "#7f849c"
  property color overlay0: "#6c7086"
  property color surface2: "#585b70"
  property color surface1: "#45475a"
  property color surface0: "#313244"
  property color base: "#1e1e2e"
  property color mantle: "#181825"
  property color crust: "#11111b"

  property string fontFamily: "SpaceMono Nerd Font"
  property int fontSize: 16

  property int cpuUsage: 0
  property int memUsage: 0
  property int temprature: 0
  property int gpuUsage: 0
  property int noNoti: 0
  property bool dnd: false
  property string curPowerProfile: "balanced"
  property int brightness: 100
  property var lastCpuIdle: 0
  property var lastCpuTotal: 0
  Process {
    id: commandRunner
  }

  TopBar {
    id: topBar
  }
  PowerMenu {
    id: powerMenu
  }

  Process {
    id: cpuProc
    command: ["sh", "-c", "head -1 /proc/stat"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var p = data.trim().split(/\s+/)
        var idle = parseInt(p[4]) + parseInt(p[5])
        var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)
        if (lastCpuTotal > 0) {
          cpuUsage = Math.round(100 * (1 - (idle - lastCpuIdle) / (total - lastCpuTotal)))
        }
        lastCpuTotal = total
        lastCpuIdle = idle
      }
    }
    Component.onCompleted: running = true
  }
  Process {
    id: memProc
    command: ["sh", "-c", "free | grep Mem"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var parts = data.trim().split(/\s+/)
        var total = parseInt(parts[1]) || 1
        var used = parseInt(parts[2]) || 0
        memUsage = Math.round(100 * used / total)
      }
    }
    Component.onCompleted: running = true
  }
  Process {
    id: tempProc
    command: ["sh", "-c", "cat /sys/class/thermal/thermal_zone0/temp"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var rawTemp = parseInt(data.trim())
        if (!isNaN(rawTemp)) {
          var celsius = Math.round(rawTemp / 1000)
          temprature = celsius
        }
      }
    }
    Component.onCompleted: running = true
  }
  Process {
    id: gpuProc
    command: ["sh", "-c", "cat /sys/class/drm/card*/device/gpu_busy_percent"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        if (!isNaN(data)) {
          gpuUsage = parseInt(data)
        }
      }
    }
    Component.onCompleted: running = true
  }
  Process {
    id: notificationsUpdate
    command: ["sh", "-c", "swaync-client -swb"]
    stdout: SplitParser {
      splitMarker: "\n"
      onRead: data => {
        var json = JSON.parse(data)
        if (json.text !== undefined) {
          noNoti = parseInt(json.text, 10) || 0;
        }
        if (json.class !== undefined) {
          dnd = json.alt.includes("dnd")
        }
      }
    }
    Component.onCompleted: running = true
  }
  Process {
    id: powerProfileUpdate
    command: ["tuned-adm", "active"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var items = data.split(": ")
        curPowerProfile = items[1]
      }
    }
    Component.onCompleted: running = true
  }
  Process {
    id: backlightUpdate
    command: ["brightnessctl", "g", "-P"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        brightness = parseInt(data)
      }
    }
    Component.onCompleted: running = true
  }
  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: {
      cpuProc.running = true
      memProc.running = true
      gpuProc.running = true
      tempProc.running = true
      notificationsUpdate.running = true
      powerProfileUpdate.running = true
    }
  }
  Timer {
    interval: 200
    running: true
    repeat: true
    onTriggered: {
      backlightUpdate.running = true
    }
  }
}
