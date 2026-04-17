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
from fabric.widgets.datetime import DateTime
from fabric.widgets.image import Image
from fabric.widgets.wayland import WaylandWindow as Window

from mpd import MPDClient

import os, subprocess, json, yaml
from pathlib import Path
import tempfile
import mimetypes
import time
from functools import partial

monitors = json.loads(subprocess.run(["/usr/bin/hyprctl", "monitors", "-j"], stdout=subprocess.PIPE).stdout.decode("utf-8"))
monitor_conf = {}

client = MPDClient()
client.timeout = 10
client.connect("localhost", 6600)

music_title = ""
music_album = ""
music_artist = ""
music_length = 0
music_time = 0
music_cover = ""
music_playing = False
music_playlist = 0
music_playlist_pos = 0 

notifications_json = json.loads(subprocess.run(["/usr/bin/dunstctl", "history"], stdout=subprocess.PIPE).stdout.decode("utf-8"))
notifications = notifications_json["data"][0]

class Menu(Window):
    def __init__(self, **kwargs):
        super().__init__(
            title="system-menu",
            name="system-menu",
            layer="top",
            anchor="top left",
            margin="18px 0px 0px 18px",
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
                                    Button(label="", name="windows", style_classes = ["menu_hori", "bottom"], on_clicked=lambda: self._direct_run("doas grub2-reboot 4 && systemctl reboot")),
                                    Button(label="󰜉", name="reboot", style_classes = ["menu_hori", "bottom"], on_clicked=lambda: self._direct_run("systemctl reboot")),
                                    Button(label="󰗼", name="exit", style_classes = ["menu_hori", "bottom"], on_clicked=lambda: self._direct_run("hyprctl dispatch exit"))
                                ]
                            )
                        ],
                    )
                ]
            )
        )
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
        os.system(f'/bin/bash ~/.config/hypr/scripts/display_mode.sh "{item}"')
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
        os.system(f'/bin/bash ~/.config/hypr/scripts/resolution_selector.sh "{res}" "{monitor}" "{str(scale)}" "{monitors[self.selected]["x"]}x{monitors[self.selected]["y"]}"')
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

class Notification(Window):
    def __init__(self, **kwargs):
        super().__init__(
            title="notification-center",
            name="notification-center",
            layer="top",
            anchor="top-right",
            margin="18px 18px 0px 0px",
            exclusivity="none",
            v_expand=True,
            keyboard_mode="on-demand",
        )
        self.connect("key-press-event", self._on_key_press)
        self.res_list=Box(
            orientation="v",
            spacing=10,
        )
        self.add(
            Box(
                name="main-box",
                orientation="v",
                spacing=10,
                size=[500,500],
                children=[
                    Box(
                        orientation="h",
                        spacing=20,
                        children=[
                            Label("Notifications",style_classes=["font-large"]),
                            DateTime(
                                formatters="%I:%M:%S %p\n%A %d of %B %Y",
                                h_align="end",
                                name="time"
                            )
                        ]
                    ),
                    ScrolledWindow(
                        min_content_size=[250, 300],
                        size=[500,300],
                        h_scrollbar_policy="never",
                        v_expand=True,
                        h_align="start",
                        child=self.res_list,
                    )
                ]
            )
        )
        self.visible = False
        self.hide()
        self.update()
    def update(self):
        global notifications
        self.res_list.children = []
        for notification in notifications:
            self.res_list.add(
                Box(
                    orientation="v",
                    spacing=10,
                    children=[
                        Label(
                            notification["body"]["data"],
                            max_chars_width=80,
                            line_wrap="word",
                            h_align="start"
                        )
                    ]
                )
            )

    def _on_key_press(self, _, event):
        if event.keyval == Gdk.KEY_Escape:
            self.visible = False
            self.hide()

class Music(Window):
    def __init__(self, **kwargs):
        super().__init__(
            title="music-center",
            name="music-center",
            layer="top",
            anchor="top-center",
            margin="18px 0px 0px 0px",
            exclusivity="none",
            v_expand=True,
            keyboard_mode="on-demand",
        )
        self.connect("key-press-event", self._on_key_press)
        self.cover = Box(children=[Image(size=[150,150])])
        self.list = Box(
            orientation="v",
            spacing=10,
            h_align="start",
            size=[400,150]
        )
        self.progress = Box(
            orientation="h",
            name = "progress_bar",
            size = [600,20]
        )
        self.add(
            Box(
                name="main-box-no-padding",
                orientation="v",
                children=[
                   Box(
                        orientation="h",
                        spacing=20,
                        size=[600,200],
                        style_classes=["padding-20"],
                        children=[
                            self.cover,
                            self.list
                        ]
                    ),
                    self.progress,
                ]
            )
        )
        self.add_keybinding("q", lambda self, _: self.hide())
        self.add_keybinding("x", lambda self, _: subprocess.run(["/usr/bin/mpc", "seekthrough", "-5"])),
        self.add_keybinding("b", lambda self, _: subprocess.run(["/usr/bin/mpc", "prev"])),
        self.add_keybinding("c", lambda self, _: subprocess.run(["/usr/bin/mpc", "toggle"])),
        self.add_keybinding("n", lambda self, _: subprocess.run(["/usr/bin/mpc", "next"])),
        self.add_keybinding("v", lambda self, _: subprocess.run(["/usr/bin/mpc", "seekthrough", "5"]))
        self.visible = False
        self.hide()
    def update(self):
        self.cover.children = [Image(image_file = music_cover,size=[150,150])]
        self.list.children = []
        self.list.add(Label(music_title, style_classes=["font-medium"], h_align="start", ellipsization="end"))
        self.list.add(Label(f"{music_artist} • {music_album}", h_align="start", ellipsization="end"))
        self.list.add(
            Label(
                f"{time.strftime("%M:%S", time.gmtime(music_time))}/{time.strftime("%M:%S", time.gmtime(music_length))} • {music_playlist_pos}/{music_playlist}",
                h_align="start"
            )
        )
        if music_playing == True:
            play_icon = ""
        else:
            play_icon = ""
        self.list.add(
            Box(
                orientation="h",
                h_align="center",
                h_expand=True,
                spacing=10,
                children=[
                    Button(label="", style_classes = ["menu_hori"], on_clicked=lambda: subprocess.run(["/usr/bin/mpc", "seekthrough", "-5"])),
                    Button(label="󰒮", style_classes = ["menu_hori"], on_clicked=lambda: subprocess.run(["/usr/bin/mpc", "prev"])),
                    Button(label=play_icon, style_classes = ["menu_hori"], on_clicked=lambda: subprocess.run(["/usr/bin/mpc", "toggle"])),
                    Button(label="󰒭", style_classes = ["menu_hori"], on_clicked=lambda: subprocess.run(["/usr/bin/mpc", "next"])),
                    Button(label="", style_classes = ["menu_hori"], on_clicked=lambda: subprocess.run(["/usr/bin/mpc", "seekthrough", "5"])),
                ]
            )
        )
        self.progress.children = [Box(name = "progress_time", size=[int((music_time/music_length)*600),20])]
    def _on_key_press(self, _, event):
        if event.keyval == Gdk.KEY_Escape:
            self.hide()

global system_menu
global notification_center

def toggle_system_menu():
    global system_menu_vis
    if system_menu.visible:
        system_menu.hide()
        system_menu.visible = False
    else:
        system_menu.show()
        system_menu.visible = True

def toggle_notification_center():
    global notification_center_vis
    global notifications
    global notifications_json
    if notification_center.visible:
        notification_center.hide()
        notification_center.visible = False
    else:
        notifications_json = json.loads(subprocess.run(["/usr/bin/dunstctl", "history"], stdout=subprocess.PIPE).stdout.decode("utf-8"))
        notifications = notifications_json["data"][0]
        notification_center.update()
        notification_center.show()
        notification_center.visible = True


if __name__ == "__main__":
    monitor_settings = Monitor()
    monitor_resolution = Resolution()
    monitor_brightness = Brightness()
    system_menu = Menu()
    notification_center = Notification()
    music_center = Music()

    def on_monitors_changed(f, v):
        global monitors
        global monitor_conf
        monitors = json.loads(v.strip())
        monitor_brightness.update_list()
        with open(os.path.dirname(os.path.realpath(__file__))+"/config.yml") as f:
            monitor_conf = yaml.safe_load(f)
        monitor_resolution.update_list()

    def on_music_changed(f, v):
        global music_title
        global music_album
        global music_artist
        global music_length
        global music_time
        global music_cover
        global music_playing
        global music_playlist
        global music_playlist_pos
        current = client.currentsong()
        cover_data = client.readpicture(current["file"])
        mime_type = cover_data.get("type")
        extension = mimetypes.guess_extension(mime_type) if mime_type else ".bin"
        if not extension:
            extension = ".jpg"
        temp_path = os.path.join(tempfile.gettempdir(), f"music_center_cover{extension}")
        try:
            with open(temp_path, 'wb') as f:
                f.write(cover_data['binary'])
        except Exception as e:
            print(f"Failed to write file: {e}")
        music_cover = temp_path

        music_title = current["title"]
        music_artist = current["artist"]
        music_album = current["album"]
        status = client.status()
        music_time = float(status["elapsed"])
        music_length = float(status["duration"])
        music_playlist = status["playlistlength"]
        music_playlist_pos = status["song"]
        if status["state"] == "play":
            music_playing = True
        else:
            music_playing = False
        music_center.update()

    monitors_fabricator = Fabricator(
        interval=1000*5,
        poll_from=lambda f: subprocess.run(["/usr/bin/hyprctl", "monitors", "-j"], stdout=subprocess.PIPE).stdout.decode("utf-8"),
        on_changed=on_monitors_changed
    )
    music_fabricator = Fabricator(
        interval=1000,
        poll_from=lambda f: subprocess.run(["/usr/bin/mpc", "current"], stdout=subprocess.PIPE).stdout.decode("utf-8"),
        on_changed=on_music_changed
    )

    app = Application("Widgets")
    app.add_window(monitor_settings)
    app.add_window(monitor_resolution)
    app.add_window(monitor_brightness)
    app.add_window(system_menu)
    app.add_window(notification_center)
    app.add_window(music_center)

    app.set_stylesheet_from_file(os.path.dirname(os.path.realpath(__file__))+"/style.css")
    app.run()
