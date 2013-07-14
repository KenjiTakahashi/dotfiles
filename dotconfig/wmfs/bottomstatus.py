# -*- coding: utf-8 -*-


import subprocess
from time import sleep
from os import path
import re
from datetime import datetime
from calendar import monthrange
from common import Mixer


class Dang(Mixer):
    def battery(self):
        data = subprocess.check_output(["acpi", "-b"]).decode('utf8')
        data = re.split(': |, |\n', data)[1:-1]
        lvl = int(data[1][:-1])
        o, length = self.do_graph(lvl, 100, True)
        o += self.square(lvl, length, True) + self.sep(True)
        if len(data) == 3:
            val = data[2].split(' ')[0].split(':')
            try:
                val = int(val[0]) * 60 + int(val[1])
            except ValueError:
                val = 0
            v, length = self.do_graph(
                data[0] == "Discharing" and -val or val, val, True
            )
            o += v + self.square(val, length, True) + self.sep(True)
        return o

    def datetime(self):
        now = datetime.now()
        t = now.time()
        o, length = self.do_graph(now.year, now.year, True)
        o += self.square(now.year, length, True) + self.sep(True)
        datas = [
            (now.month, 12), (now.day, monthrange(now.year, now.month)[1]),
            (t.second, 59), (t.minute, 59), (t.hour, 23)
        ]
        for val, max_ in datas:
            v, length = self.do_graph(val, max_, True)
            o += v + self.square(val, length, True) + self.sep(True)
        return o

    def run(self):
        self.xloffset = 0
        self.xroffset = 1208
        return "bottom {}{}".format(
            self.datetime(),
            self.battery()
        )


dang = Dang()
while True:
    try:
        result = dang.run()
    except Exception as e:
        import traceback
        with open(path.expanduser('~/.cache/wmfs/log_bottom'), 'a') as f:
            traceback.print_exc(file=f)
    else:
        subprocess.call(["wmfs", "-c", "status", result])
    sleep(1)
