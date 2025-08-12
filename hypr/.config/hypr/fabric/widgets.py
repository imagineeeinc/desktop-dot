import fabric
from gi.repository import Gdk
from fabric import Application, Fabricator
from fabric.widgets.box import Box
from fabric.widgets.centerbox import CenterBox
from fabric.widgets.label import Label
from fabric.widgets.button import Button
from fabric.widgets.entry import Entry
from fabric.widgets.circularprogressbar import CircularProgressBar
from fabric.widgets.eventbox import EventBox
from fabric.widgets.wayland import WaylandWindow as Window

import os, subprocess, json, copy
from pathlib import Path
from functools import partial

monitors = json.loads(subprocess.run(["/usr/bin/hyprctl", "monitors", "-j"], stdout=subprocess.PIPE).stdout.decode("utf-8"))

class Monitor(Window):
    def __init__(self, **kwargs):
        super().__init__(
            title="Monitor Settings",
            name="monitor-settings",
            layer="top",
            anchor="center",
            exclusivity="none",
            keyboard_mode="on-demand",
        )
        self.connect("key-press-event", self._on_key_press)
        self.add(
            Box(
                name="main-box",
                orientation="v",
                spacing=10,
                children=[
                    Label("Monitor Placement Settings"),
                    Box(
                        orientation="v",
                        spacing=10,
                        children=[
                            Button(label="Screen 1",     on_clicked=lambda: self._monitor_switch("Screen1")),
                            Button(label="Screen 2",     on_clicked=lambda: self._monitor_switch("Screen2")),
                            Button(label="Mirror",       on_clicked=lambda: self._monitor_switch("Mirror")),
                            Button(label="Extend Above", on_clicked=lambda: self._monitor_switch("Extend Above")),
                            Button(label="Extend Right", on_clicked=lambda: self._monitor_switch("Extend Right")),
                            Button(label="Extend Left",  on_clicked=lambda: self._monitor_switch("Extend Left")),
                        ],
                    )
                ]
            )
        )
        self.add_keybinding("esc", lambda self, _: quit(0))
        self.add_keybinding("1", lambda self, _: self._monitor_switch("Screen1")),
        self.add_keybinding("2", lambda self, _: self._monitor_switch("Screen2")),
        self.add_keybinding("3", lambda self, _: self._monitor_switch("Mirror")),
        self.add_keybinding("4", lambda self, _: self._monitor_switch("Extend Above")),
        self.add_keybinding("5", lambda self, _: self._monitor_switch("Extend Right")),
        self.add_keybinding("6", lambda self, _: self._monitor_switch("Extend Left")),
        self.hide()

    def _on_key_press(self, _, event):
        if event.keyval == Gdk.KEY_Escape:
            self.hide()
    def _monitor_switch(self, item):
        os.system(f'/bin/bash ../display_mode.sh "{item}"')
        self.hide()

class Resolution(Window):
    def __init__(self, **kwargs):
        super().__init__(
            title="Resolution Settings",
            name="resolution-settings",
            layer="top",
            anchor="center",
            exclusivity="none",
            keyboard_mode="on-demand",
        )
        # TODO: Add per monitor setting
        self.connect("key-press-event", self._on_key_press)
        self.input_box = Entry(placeholder="Resolution")
        self.add(
           Box(
                name="main-box",
                orientation="v",
                spacing=10,
                children=[
                    Label("Monitor Resolution Settings"),
                    self.input_box,
                    Button(label="Standard",   on_clicked=lambda: self._handle_press("Standard")),
                    Button(label="1920x1080",  on_clicked=lambda: self._handle_press("1920x1080"))
                ]
            )
        )
        self.hide()
    def _on_key_press(self, _, event):
        if event.keyval == Gdk.KEY_Escape:
            self.hide()
        elif event.keyval == Gdk.KEY_Return:
            if type(self.get_focus()).__name__ == "Entry":
                value = self.input_box.get_text()
                os.system(f'/bin/bash ../resolution_selector.sh "{value}"')
                self.hide()
    def _handle_press(self, item):
        os.system(f'/bin/bash ../resolution_selector.sh "{item}"')
        self.hide()

class Brightness(Window):
    def __init__(self, **kwargs):
        super().__init__(
            title="Resolution Settings",
            name="resolution-settings",
            layer="top",
            anchor="top right",
            margin="25px 25px 0px 0px",
            exclusivity="none",
            keyboard_mode="on-demand",
        )
        self.connect("key-press-event", self._on_key_press)
        self.list=Box(
            orientation="h",
            spacing=10
        )
        self.add(
           Box(
                name="main-box",
                orientation="v",
                spacing=20,
                children=[
                    Label("Monitor Brightness"),
                    self.list
                ]
            )
        )
        self.update_list()
        self.hide()
    def _on_key_press(self, _, event):
        if event.keyval == Gdk.KEY_Escape:
            self.hide()
    def update_list(self):
        self.list.children = []
        for index, monitor in enumerate(monitors):
            if monitor["name"] == "eDP-1":
                brightness = subprocess.run(["/usr/bin/brightnessctl" ,"g", "--percentage"], stdout=subprocess.PIPE).stdout.decode("utf-8")
            else:
                brightness = subprocess.run(["/usr/bin/ddcutil", "-d" ,"1", "getvcp" ,"10"], stdout=subprocess.PIPE).stdout.decode("utf-8")
                brightness = brightness.split('current value =')[1]
                brightness = brightness.split(',')[0].strip()
            self.list.add(
                Box(
                    orientation="v",
                    spacing=5,
                    children=[
                        Label(f"{monitor["name"]}"),
                        CircularProgressBar(
                            value=float(brightness),
                            min_value=0.0,
                            max_value=100.0,
                            line_width=10,
                            style_classes=["circularprogress"],
                            size=[100,100]
                        ),
                        Box(
                            orientation="h",
                            spacing=10,
                            children=[
                                Button(label="+", on_clicked=partial(self._handle_brightness, "+", f"{monitor["name"]}", index)),
                                Button(label="-", on_clicked=partial(self._handle_brightness, "-", f"{monitor["name"]}", index))
                            ]
                        )
                    ]
                )
            )
    def _handle_brightness(self, event, disp, index):
        if disp == "eDP-1":
            if event == "+":
                os.system("brightnessctl s 5%+")
            elif event == "-":
                os.system("brightnessctl s 5%-")
            self.list.children[index].children[1].value = float(subprocess.run(["/usr/bin/brightnessctl" ,"g", "--percentage"], stdout=subprocess.PIPE).stdout.decode("utf-8"))
        else:
            disp_parts = disp.split("-")
            brightness = subprocess.run(["/usr/bin/ddcutil", "-d" , disp_parts[len(disp_parts)-1], "getvcp" ,"10"], stdout=subprocess.PIPE).stdout.decode("utf-8")
            brightness = brightness.split('current value =')[1]
            brightness = brightness.split(',')[0].strip()
            if event == "+":
                os.system(f"ddcutil --display {disp_parts[len(disp_parts)-1]} setvcp 10 {int(brightness)+5}")
                self.list.children[index].children[1].value = int(brightness)+5
            elif event == "-":
                os.system(f"ddcutil --display {disp_parts[len(disp_parts)-1]} setvcp 10 {int(brightness)-5}")
                self.list.children[index].children[1].value = int(brightness)-5

if __name__ == "__main__":
    monitor_settings = Monitor()
    monitor_resolution = Resolution()
    monitor_brightness = Brightness()
    def on_monitors_changed(f, v):
        global monitors
        monitors = json.loads(v.strip())
        monitor_brightness.update_list()

    monitors_fabricator = Fabricator(
        interval=1000*5,
        poll_from=lambda f: subprocess.run(["/usr/bin/hyprctl", "monitors", "-j"], stdout=subprocess.PIPE).stdout.decode("utf-8"),
        on_changed=on_monitors_changed
    )

    app = Application("Widgets")
    app.add_window(monitor_settings)
    app.add_window(monitor_resolution)
    app.add_window(monitor_brightness)

    app.set_stylesheet_from_file("./style.css")
    app.run()
