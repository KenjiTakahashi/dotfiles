# -*- coding: utf-8 -*-


import subprocess
from time import sleep
from os import statvfs
from urllib.parse import urlencode
from urllib.request import urlopen
from xml.etree import ElementTree as ET
import dbus
from common import Mixer


WEATHER_NS = 'http://xml.weather.yahoo.com/ns/rss/1.0'
WEATHER_URL = 'http://weather.yahooapis.com/forecastrss?'
PLAYER_URI = 'org.mpris.MediaPlayer2.gayeogi'
PLAYER_NS = '/org/mpris/MediaPlayer2'
PLAYER_ICE = 'org.freedesktop.DBus.Properties'


class Dang(Mixer):
    def __init__(self):
        super().__init__()
        self.CPU_BUSY = 0
        self.CPU_IDLE = 0
        self.weather_data = [0, 0]
        self.rxv = 0
        self.txv = 0
        self.bus = dbus.SessionBus()
        self.player = None

    def cpu(self):
        with open('/proc/stat') as f:
            data = f.readline().split(' ')
        user = int(data[2])
        nice = int(data[3])
        sys_ = int(data[4])
        idle = int(data[5])
        busy = user + nice + sys_ - self.CPU_BUSY
        total = busy + idle - self.CPU_IDLE
        if total:
            out = round(busy * 100. / total)
            self.CPU_BUSY = user + nice + sys_
            self.CPU_IDLE = idle
        graph, length = self.do_graph(out, 100)
        return "{}{}".format(graph, self.square(out, length))

    def mem(self):
        vals = dict()
        with open('/proc/meminfo') as f:
            for line in f:
                key, value = line.split(':')
                vals[key] = round(int(value.split()[0]) / 1024)
        mtotal = vals['MemTotal']
        mused = mtotal - vals['MemFree'] - vals['Buffers'] - vals['Cached']
        stotal = vals['SwapTotal']
        sused = stotal - vals['SwapFree'] - vals['SwapCached']
        mgraph, mlength = self.do_graph(mused, mtotal)
        msquare = self.square(mused, mlength)
        sep = self.sep()
        sgraph, slength = self.do_graph(sused, stotal)
        ssquare = self.square(sused, slength)
        return "{}{}{}{}{}".format(mgraph, msquare, sep, sgraph, ssquare)

    def hdd(self, path):
        s = statvfs(path)
        used = round((s.f_blocks - s.f_bfree) * s.f_frsize / 1048576)
        total = round(s.f_blocks * s.f_frsize / 1048576)
        graph, length = self.do_graph(used, total)
        return "{}{}".format(graph, self.square(used, length))

    def weather(self, woeid):
        if not self.weather_data[0]:
            uri = "{}{}".format(WEATHER_URL, urlencode({'w': woeid, 'u': 'c'}))
            try:
                x = urlopen(uri).read().decode('utf8')
            except Exception as e:
                import traceback
                with open('/home/kenji/.cache/wmfs/log_top', 'a') as f:
                    traceback.print_exc(file=f)
                return ""
            e = ET.fromstring(x).find('.//{{{}}}condition'.format(WEATHER_NS))
            data = int(e.attrib['temp'])
            self.weather_data[1] = data
        else:
            data = self.weather_data[1]
        self.weather_data[0] += 1
        self.weather_data[0] %= 3000
        graph, length = self.do_graph(data, data, right=True)
        return "{}{}".format(graph, self.square(data, length, right=True))

    def net(self, ice):
        path = "/sys/class/net/{}/statistics/".format(ice)
        rxp = "{}rx_bytes".format(path)
        txp = "{}tx_bytes".format(path)
        with open(rxp) as rx, open(txp) as tx:
            nrxv = int(rx.read())
            ntxv = int(tx.read())
            rxv = nrxv - self.rxv
            txv = ntxv - self.txv
            self.rxv = nrxv
            self.txv = ntxv
        return "{}{}{}".format(
            self.do_graph(rxv, rxv, right=True)[0],
            self.sep(right=True),
            self.do_graph(txv, txv, right=True)[0]
        )

    def np(self):
        if not self.player:
            try:
                proxy = self.bus.get_object(PLAYER_URI, PLAYER_NS)
                self.player = dbus.Interface(proxy, PLAYER_ICE)
            except Exception:
                pass
        if self.player:
            try:
                meta = self.player.Get(
                    'org.mpris.MediaPlayer2.Player', 'Metadata'
                )
                if meta['mpris:trackid'] == '/gayeogi/notrack':
                    return ""
                return "\s[{};11;{};{{1\[}}{}{{1\]}}{}{{1 from}} {}{{1 by}} {}]".format(  # NOPEP8
                    self.xloffset + 4,
                    self.fg2,
                    meta['xesam:trackNumber'],
                    meta['xesam:title'].replace(']', '\]'),
                    meta['xesam:album'].replace(']', '\]'),
                    meta['xesam:artist'][0].replace(']', '\]')
                )
            except Exception:
                self.player = None
        return ""

    def run(self):
        self.xloffset = 0
        self.xroffset = 1358
        return "top {}{}{}{}{}{}{}{}{}{}{}{}{}{}{}".format(
            self.cpu(),
            self.sep(),
            self.mem(),
            self.sep(),
            self.hdd('/'),
            self.sep(),
            self.hdd('/home/kenji'),
            self.sep(),
            self.hdd('/mnt/music'),
            self.sep(),
            self.np(),
            self.weather(526363),
            self.sep(right=True),
            self.net('wlan0'),
            self.sep(right=True)
        )


dang = Dang()
while True:
    try:
        result = dang.run()
    except Exception as e:
        import traceback
        with open('/home/kenji/.cache/wmfs/log_top', 'a') as f:
            traceback.print_exc(file=f)
    else:
        subprocess.call(["wmfs", "-c", "status", result])
    sleep(1)
