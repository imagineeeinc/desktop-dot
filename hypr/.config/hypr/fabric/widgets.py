import fabric
from gi.repository import Gdk
from fabric import Application, Fabricator
from fabric.widgets.box import Box
from fabric.widgets.centerbox import CenterBox
from fabric.widgets.label import Label
from fabric.widgets.button import Button
from fabric.widgets.entry import Entry
from fabric.widgets.circularprogressbar import CircularProgressBar
from fabric.widgets.scrolledwindow import ScrolledWindow
from fabric.widgets.revealer import Revealer
from fabric.widgets.wayland import WaylandWindow as Window

import os, subprocess, json, yaml
from pathlib import Path
from functools import partial

monitors = json.loads(subprocess.run(["/usr/bin/hyprctl", "monitors", "-j"], stdout=subprocess.PIPE).stdout.decode("utf-8"))
monitor_conf = {}
class Menu(Window):
    def __init__(self, **kwargs):
        super().__init__(
            title="system-menu",
            name="system-menu",
            layer="top",
            anchor="top left",
            margin="1px 0px 0px 15px",
            exclusivity="none",
            keyboard_mode="on-demand",
        )
        self.connect("key-press-event", self._on_key_press)
        self.cmds = [
            "hyprsysteminfo &",
            "wlogout &",
            "kitty &",
            "dolphin &",
            "kitty btop &",
            "plasma-discover &",
            "kitty --class=rmpc rmpc &"
        ]
        self.add(
            Box(
                name="menu",
                orientation="v",
                spacing=10,
                children=[
                    Box(
                        orientation="v",
                        spacing=0,
                        children=[
                            Box(
                                orientation="h",
                                h_align="center",
                                h_expand=True,
                                spacing=10,
                                name="menu_hori",
                                children=[
                                    Button(label="󰒮", style_classes = ["menu_hori"], on_clicked=lambda: self._direct_run("playerctl previous", hide=False)),
                                    Button(label="", style_classes = ["menu_hori"], on_clicked=lambda: self._direct_run("playerctl play-pause", hide=False)),
                                    Button(label="󰒭", style_classes = ["menu_hori"], on_clicked=lambda: self._direct_run("playerctl next", hide=False))
                                ]
                            ),
                            Box(style_classes = ["spacer"]),
                            Button(label="About HoshiOS",          on_clicked=lambda: self._run(0)),
                            Button(label="Power Menu",     on_clicked=lambda: self._run(1)),
                            Box(style_classes = ["spacer"]),
                            Button(label="Terminal",       on_clicked=lambda: self._run(2)),
                            Button(label="Explorer",       on_clicked=lambda: self._run(3)),
                            Button(label="System Monitor", on_clicked=lambda: self._run(4)),
                            Button(label="Store",          on_clicked=lambda: self._run(5)),
                            Button(label="Music player",   on_clicked=lambda: self._run(6)),
                            Box(style_classes = ["spacer"]),
                            Box(
                                orientation="h",
                                spacing=2,
                                name="menu_hori",
                                children=[
                                    Button(label="", name="poweroff", style_classes = ["menu_hori", "bottom"], on_clicked=lambda: self._direct_run("systemctl poweroff")),
                                    Button(label="", name="windows", style_classes = ["menu_hori", "bottom"], on_clicked=lambda: self._direct_run("doas grub2-reboot 3 && systemctl reboot")),
                                    Button(label="󰜉", name="reboot", style_classes = ["menu_hori", "bottom"], on_clicked=lambda: self._direct_run("systemctl reboot")),
                                    Button(label="󰗼", name="exit", style_classes = ["menu_hori", "bottom"], on_clicked=lambda: self._direct_run("hyprctl dispatch exit"))
                                ]
                            )
                        ],
                    )
                ]
            )
        )
        self.add_keybinding("esc", lambda self, _: quit(0))
        self.add_keybinding("1", lambda self, _: self._run(0)),
        self.add_keybinding("2", lambda self, _: self._run(1)),
        self.add_keybinding("3", lambda self, _: self._run(2)),
        self.add_keybinding("4", lambda self, _: self._run(3)),
        self.add_keybinding("5", lambda self, _: self._run(4)),
        self.add_keybinding("6", lambda self, _: self._run(5))
        self.add_keybinding("7", lambda self, _: self._run(6))

        self.add_keybinding("b", lambda self, _: self._direct_run("playerctl previous", hide=False)),   
        self.add_keybinding("c", lambda self, _: self._direct_run("playerctl play-pause", hide=False)), 
        self.add_keybinding("n", lambda self, _: self._direct_run("playerctl next", hide=False))        

        self.visible = False
        self.hide()

    def _on_key_press(self, _, event):
        if event.keyval == Gdk.KEY_Escape:
            self.visible = False
            self.hide()
    def _direct_run(self, cmd, hide = True):
        os.system(f'{cmd}')
        if hide == True:
            self.visible = False
            self.hide()
    def _run(self, cmd):
        os.system(f'{self.cmds[cmd]}')
        self.visible = False
        self.hide()

class Monitor(Window):
    def __init__(self, **kwargs):
        super().__init__(
            title="monitor-settings",
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
        os.system(f'/bin/bash ~/.config/hypr/display_mode.sh "{item}"')
        self.hide()

class Resolution(Window):
    def __init__(self, **kwargs):
        super().__init__(
            title="resolution-settings",
            name="resolution-settings",
            layer="top",
            anchor="top right",
            margin="18px 18px 0px 0px",
            exclusivity="none",
            keyboard_mode="on-demand",
        )
        self.connect("key-press-event", self._on_key_press)
        self.input_box = Entry(placeholder="Resolution")
        self.selected=0
        self.list=Box(
            orientation="h",
            spacing=5
        )
        self.res_list=Box(
            orientation="v",
            spacing=10
        )
        self.search_term = ""
        self.add(
           Box(
                name="main-box",
                orientation="h",
                spacing=20,
                children=[
                    Box(
                        orientation="v",
                        spacing=10,
                        children=[
                            Label("Monitor Resolution Settings"),
                            self.list,
                            self.input_box,
                            ScrolledWindow(
                                min_content_size=[250, 300],
                                h_scrollbar_policty="never",
                                v_expand=True,
                                child=self.res_list
                            )
                        ]
                    ),
                    Button(
                        label="",
                        style_classes=["close-btn", "font-large", "font-lavender"],
                        on_clicked=lambda: self.hide(),
                    )
                    # Button(label="Standard",   on_clicked=lambda: self._handle_press("Standard")),
                    # Button(label="1920x1080",  on_clicked=lambda: self._handle_press("1920x1080"))
                ]
            )
        )
        self.update_list()
        self.hide()
    def _on_key_press(self, _, event):
        if event.keyval == Gdk.KEY_Escape:
            self.hide()
        elif event.keyval == Gdk.KEY_Return:
            if type(self.get_focus()).__name__ == "Entry":
                value = self.input_box.get_text()
                self._handle_press(value, monitors[self.selected]["name"])
                self.hide()
        else:
            self.search_term = self.input_box.get_text()
            self.update_list()
    def update_list(self):
        self.list.children = []
        for index, monitor in enumerate(monitors):
            classes = ["font-medium"]
            if index == self.selected:
                classes.append("selected")
                self.res_list.children = []
                for res in monitor["availableModes"]:
                    if len(self.search_term) == 0 or self.search_term in res:
                        self.res_list.add(
                            Button(label=res, on_clicked=partial(self._handle_press, res, monitor["name"]))
                        )
            self.list.add(
                Button(
                    label=monitor["name"],
                    style_classes=classes,
                    h_exapnd=True,
                    on_clicked=partial(self._set_selected, index)
                )
            )
    def _set_selected(self, i):
        self.selected = i
    def _handle_press(self, res, monitor):
        monitor_c = [m for m in monitor_conf["monitors"] if m["name"] == monitor]
        scale = monitors[self.selected]["scale"]
        if len(monitor_c):
            scale_c = [r["scale"] for r in monitor_c[0]["resolutions"] if res in r["name"]]
            if len(scale_c) > 0:
                scale = scale_c[0] or 1
        os.system(f'/bin/bash ~/.config/hypr/resolution_selector.sh "{res}" "{monitor}" "{str(scale)}" "{monitors[self.selected]["x"]}x{monitors[self.selected]["y"]}"')
        self.hide()

class Brightness(Window):
    def __init__(self, **kwargs):
        super().__init__(
            title="brightness-settings",
            name="brightness-settings",
            layer="top",
            anchor="top right",
            margin="18px 18px 0px 0px",
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
                orientation="h",
                spacing=20,
                children=[
                    Box(
                        orientation="v",
                        spacing=20,
                        children=[
                            Label("Monitor Brightness"),
                            self.list
                        ]
                    ),
                    Button(
                        label="",
                        style_classes=["close-btn", "font-large", "font-lavender"],
                        on_clicked=lambda: self.hide(),
                    )
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
                brightness = subprocess.run(["/usr/bin/ddcutil", "-d" ,"1", "getvcp", "10"], stdout=subprocess.PIPE).stdout.decode("utf-8")
                if brightness.startswith("VCP code 0x10"):
                    brightness = brightness.split('current value =')[1]
                    brightness = brightness.split(',')[0].strip()
                else:
                    continue
            self.list.add(
                Box(
                    orientation="v",
                    spacing=10,
                    children=[
                        Label(monitor["name"]),
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
                                Button(label="+", on_clicked=partial(self._handle_brightness, "+", monitor["name"], index)),
                                Button(label="-", on_clicked=partial(self._handle_brightness, "-", monitor["name"], index))
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

global system_menu

def toggle_system_menu():
    global system_menu_vis
    if system_menu.visible:
        system_menu.hide()
        system_menu.visible = False
    else:
        system_menu.show()
        system_menu.visible = True

if __name__ == "__main__":
    monitor_settings = Monitor()
    monitor_resolution = Resolution()
    monitor_brightness = Brightness()
    system_menu = Menu()
    def on_monitors_changed(f, v):
        global monitors
        global monitor_conf
        monitors = json.loads(v.strip())
        monitor_brightness.update_list()
        with open(os.path.dirname(os.path.realpath(__file__))+"/config.yml") as f:
            monitor_conf = yaml.safe_load(f)
        monitor_resolution.update_list()

    monitors_fabricator = Fabricator(
        interval=1000*5,
        poll_from=lambda f: subprocess.run(["/usr/bin/hyprctl", "monitors", "-j"], stdout=subprocess.PIPE).stdout.decode("utf-8"),
        on_changed=on_monitors_changed
    )

    app = Application("Widgets")
    app.add_window(monitor_settings)
    app.add_window(monitor_resolution)
    app.add_window(monitor_brightness)
    app.add_window(system_menu)

    app.set_stylesheet_from_file(os.path.dirname(os.path.realpath(__file__))+"/style.css")
    app.run()
