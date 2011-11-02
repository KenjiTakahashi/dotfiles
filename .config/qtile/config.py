from libqtile import hook
from libqtile.manager import Key, Screen, Group
from libqtile.command import lazy
from libqtile import layout, bar, widget
import kwidget

modkey = "mod4"
mf = 'liberation mono'
bg = '#2d2d2d'
#fg = '#5faf5f' #green
#fg = '#5fafff' #blue
fg = '#7e3560' #purple

layout.floating.FLOAT_WM_TYPES = {
    'notification': 1,
    'splash': 1
}

keys = [
    Key([modkey], "a", lazy.layout.next()),
    Key([modkey], "d", lazy.layout.previous()),
    Key([modkey], "p", lazy.spawn(
            "dmenu_run -b -i -fn '{font}' -nb '{color}' -sb '{color}'".format(
            font = mf, color = bg))
        ),
    Key([modkey], "c", lazy.spawn("anamnesis -b")),
    Key([modkey], "Return", lazy.spawn("urxvtc")),
    Key([modkey], "space", lazy.nextlayout()),
    Key([modkey, "shift"], "space", lazy.layout.shuffle()),
    Key([modkey, "shift"], "c", lazy.window.kill()),
    Key([modkey], "w", lazy.layout.up()),
    Key([modkey], "s", lazy.layout.down()),
]

groups = [
    Group("1"),
    Group("2"),
    Group("3"),
    Group("e"),
    Group("r"),
    Group("t"),
    Group("y"),
    Group("u"),
    Group("i"),
    Group("o")
]
for i in groups:
    keys.append(Key([modkey], i.name, lazy.group[i.name].toscreen()))
    keys.append(Key([modkey, "shift"], i.name, lazy.window.togroup(i.name)))

layouts = [
    layout.Tile(border_width = 0),
    layout.RatioTile(border_width = 0),
    layout.Max(),
    layout.Floating(border_width = 0)
]

floating_layout = layout.Floating(
    border_width = 0,
    max_border_width = 0,
    fullscreen_border_width = 0
)

graphs_settings = {
    'graph_color': fg,
    'fill_color': fg,
    'background': bg,
    'border_width': 0,
    'line_width': 2,
    'margin_y': 0,
    'margin_x': 0,
    'start_pos': 'top'
}

screens = [
    Screen(
        top = bar.Bar([
            widget.CPUGraph(
                **graphs_settings
            ),
            widget.MemoryGraph(
                type = 'box',
                **graphs_settings
            ),
            widget.SwapGraph(
                type = 'box',
                **graphs_settings
            ),
            widget.NetGraph(
                interface = 'wlan0',
                **graphs_settings
            ),
            widget.NetGraph(
                interface = 'wlan0',
                bandwidth_type = 'up',
                **graphs_settings
            ),
            widget.Mpris(
                name = "gayeogi",
                objname = "org.mpris.gayeogi"
            )
        ], 16, opacity = .85, background = bg),
        bottom = bar.Bar([
            widget.GroupBox(
                font = mf,
                fontsize = 12,
                borderwidth = 0,
                background = bg,
                margin_x = 0,
                margin_y = 0,
                padding = 1,
                highlight_method = 'block',
                rounded = False,
                inactive = '000000',
                this_screen_border = fg
            ),
            widget.CurrentLayout(
                font = mf,
                fontsize = 11,
                background = bg,
                padding = 2
            ),
            widget.WindowName(
                font = mf,
                fontsize = 11,
                background = bg
            ),
            kwidget.Battery2(
                font = mf,
                fontsize = 11,
                background = bg
            ),
            widget.Clock(
                fmt = '%a %b %d %H:%M:%S %Z %Y',
                font = mf,
                fontsize = 11,
                background = bg
            )
        ], 16, opacity = .85)
    )
]

@hook.subscribe.client_managed
def opacity(window):
    if not window.match(wname = "MPlayer") and not window.match(wmclass = "vlc"):
        window.opacity = .85
