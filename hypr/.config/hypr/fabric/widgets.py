import fabric
from gi.repository import Gdk
from fabric import Application
from fabric.widgets.box import Box
from fabric.widgets.centerbox import CenterBox
from fabric.widgets.label import Label
from fabric.widgets.button import Button
from fabric.widgets.entry import Entry
from fabric.widgets.image import Image
# from fabric.widgets.window import Window
from fabric.widgets.wayland import WaylandWindow as Window

import os, subprocess
from pathlib import Path

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

if __name__ == "__main__":
    monitor_settings = Monitor()
    monitor_resolution = Resolution()
    app = Application("Widgets")
    app.add_window(monitor_settings)
    app.add_window(monitor_resolution)

    app.set_stylesheet_from_file("./style.css")
    app.run()
