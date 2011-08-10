from libqtile import manager
from libqtile.widget import battery

FULL = 'Full'

class Battery2(battery.Battery):
    defaults = manager.Defaults(
        ("font", "Arial", "Clock font"),
        ("fontsize", None, "Clock pixel size. Calculated if None."),
        ("padding", None, "Clock padding. Calculated if None."),
        ("background", "000000", "Background colour"),
        ("foreground", "ffffff", "Foreground colour"),
        ("test_format", "{char}", "lol"),
        ("format", "{char} {percent:2.0%} {hour:02d}:{min:02d}:{sec:02d}", "Display format"),
        ("full_format", "{char} {msg}{percent:2.0%}", "Full display format"),
        ("battery_name", "BAT0", "ACPI name of a battery, usually BAT0"),
        ("status_file", "status", "Name of status file in /sys/class/power_supply/battery_name"),
        ("energy_now_file", "energy_now", "Name of file with the current energy in /sys/class/power_supply/battery_name"),
        ("energy_full_file", "energy_full", "Name of file with the maximum energy in /sys/class/power_supply/battery_name"),
        ("power_now_file", "power_now", "Name of file with the current power draw in /sys/class/power_supply/battery_name"),
        ("update_delay", 1, "The delay in seconds between updates")
    )
    def __init__(self, **config):
        battery.Battery.__init__(self, **config)
    def _get_info(self):
        stat = self._get_param(self.status_file)
        now = float(self._get_param(self.energy_now_file))
        full = float(self._get_param(self.energy_full_file))
        power = float(self._get_param(self.power_now_file))

        if power != 0.0:
            if stat == battery.DISCHARGING:
                time = now / power
            elif stat == battery.CHARGING:
                time = (full - now) / power

            hour = int(time)
            min = int(time * 60) % 60
            sec = int(time * 3600) % 60
            return self.format.format(char = stat,
                    percent = now / full,
                    hour = hour, min = min, sec = sec)
        elif stat == battery.DISCHARGING or stat == battery.CHARGING:
            msg = '(at zero rate) '
        elif stat == FULL or stat == battery.UNKNOWN:
            msg = ''
        return self.full_format.format(char = stat,
                msg = msg, percent = now / full)

#class CurrentLayout(base._TextBox):
#    defaults = manager.Defaults(
#        ("font", "Arial", "Text font"),
#        ("fontsize", None, "Font pixel size. Calculated if None."),
#        ("padding", None, "Padding left and right. Calculated if None."),
#        ("background", None, "Background colour."),
#        ("foreground", "#ffffff", "Foreground colour.")
#    )
#    def __init__(self, width = bar.CALCULATED, **config):
#        base._TextBox.__init__(self, "", width, **config)
#        def hook_response(layout):
#            self.text = layout.name
#        hook.subscribe.layout_change(hook_response)
