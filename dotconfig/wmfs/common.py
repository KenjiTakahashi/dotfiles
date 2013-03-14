# -*- coding: utf-8 -*-


from math import ceil


class Mixer(object):
    def __init__(self):
        self.xloffset = 0
        self.xroffset = 1358
        self.tempoffset = 0
        self.fg1 = "#4d679a"
        self.fg2 = "#8e8e8e"
        self.fg3 = "#252727"
        self.urg = "#88002a"
        self.bg = "#383a3b"

    def square(self, val, length, right=False):
        sval = str(abs(val))
        if right:
            self.tempoffset = self.xroffset+ceil(length/2)-len(sval)*5+9
        else:
            self.tempoffset = self.xloffset-ceil(length/2)-len(sval)*5+1
        if sval[0] == '1':
            self.tempoffset += 3
        return ''.join([self.digit(s, self.tempoffset, right) for s in sval])

    def sep(self, right=False):
        out = "\R[{};0;8;16;{}]".format(self.offset(right), self.fg3)
        return out

    def do_graph(self, val, maxi, right=False):
        if val is None or (not maxi and not val):
            return ("", 0)
        o = ""
        valb = bin(val)
        valb = valb[0] == '-' and valb[3:] or valb[2:]
        maxl = len(bin(abs(maxi))[2:])
        vall = len(valb)
        c = val < 0 and self.urg or self.fg1
        if vall != maxl:
            valb = "0" * (maxl - vall) + valb
            vall = len(valb)
        if maxl % 2 == 1:
            o += "\R[{};0;8;8;{}]".format(self.soffset(right), self.fg3)
            o += "\R[{};8;8;8;{}]".format(
                self.offset(right),
                valb[0] == '1' and c or self.bg
            )
            valb = valb[1::]
        for v1, v2 in zip(valb[::2], valb[1::2]):
            y, h = 0, 16
            if v2 == "0":
                if v1 == "0":
                    c = self.bg
                else:
                    h = 8
            elif v1 == "0":
                y, h = 8, 8
            o += "\R[{};{};8;{};{}]".format(self.offset(right), y, h, c)
        return (o, ceil(vall/2) * 8)

    def soffset(self, right):
        return right and self.xroffset or self.xloffset

    def offset(self, right, d=8):
        if right:
            offset = self.xroffset
            self.xroffset -= d
        else:
            offset = self.xloffset
            self.xloffset += d
        return offset

    def digit(self, val, offset, right=False):
        self.tempoffset += 10
        if val == '0':
            return "{}{}{}{}".format(
                "\R[{};4;2;8;{}]".format(offset, self.fg2),
                "\R[{};4;4;2;{}]".format(offset + 2, self.fg2),
                "\R[{};10;4;2;{}]".format(offset + 2, self.fg2),
                "\R[{};4;2;8;{}]".format(offset + 6, self.fg2)
            )
        if val == '1':
            self.tempoffset -= 6
            return "\R[{};4;2;8;{}]".format(offset, self.fg2)
        if val == '2':
            return "{}{}{}{}{}".format(
                "\R[{};4;8;2;{}]".format(offset, self.fg2),
                "\R[{};7;8;2;{}]".format(offset, self.fg2),
                "\R[{};10;8;2;{}]".format(offset, self.fg2),
                "\R[{};9;2;1;{}]".format(offset, self.fg2),
                "\R[{};6;2;1;{}]".format(offset + 6, self.fg2)
            )
        if val == '3':
            return "{}{}{}{}".format(
                "\R[{};4;6;2;{}]".format(offset, self.fg2),
                "\R[{};7;6;2;{}]".format(offset, self.fg2),
                "\R[{};10;6;2;{}]".format(offset, self.fg2),
                "\R[{};4;2;8;{}]".format(offset + 6, self.fg2)
            )
        if val == '4':
            return "{}{}{}".format(
                "\R[{};4;2;5;{}]".format(offset, self.fg2),
                "\R[{};7;4;2;{}]".format(offset + 2, self.fg2),
                "\R[{};4;2;8;{}]".format(offset + 6, self.fg2)
            )
        if val == '5':
            return "{}{}{}{}{}".format(
                "\R[{};4;8;2;{}]".format(offset, self.fg2),
                "\R[{};7;8;2;{}]".format(offset, self.fg2),
                "\R[{};10;8;2;{}]".format(offset, self.fg2),
                "\R[{};6;2;1;{}]".format(offset, self.fg2),
                "\R[{};9;2;1;{}]".format(offset + 6, self.fg2)
            )
        if val == '6':
            return "{}{}{}{}{}".format(
                "\R[{};4;2;8;{}]".format(offset, self.fg2),
                "\R[{};4;6;2;{}]".format(offset + 2, self.fg2),
                "\R[{};7;6;2;{}]".format(offset + 2, self.fg2),
                "\R[{};10;6;2;{}]".format(offset + 2, self.fg2),
                "\R[{};9;2;1;{}]".format(offset + 6, self.fg2)
            )
        if val == '7':
            return "{}{}".format(
                "\R[{};4;6;2;{}]".format(offset, self.fg2),
                "\R[{};4;2;8;{}]".format(offset + 6, self.fg2)
            )
        if val == '8':
            return "{}{}{}{}{}".format(
                "\R[{};4;2;8;{}]".format(offset, self.fg2),
                "\R[{};4;4;2;{}]".format(offset + 2, self.fg2),
                "\R[{};7;4;2;{}]".format(offset + 2, self.fg2),
                "\R[{};10;4;2;{}]".format(offset + 2, self.fg2),
                "\R[{};4;2;8;{}]".format(offset + 6, self.fg2)
            )
        if val == '9':
            return "{}{}{}{}{}".format(
                "\R[{};4;6;2;{}]".format(offset, self.fg2),
                "\R[{};7;6;2;{}]".format(offset, self.fg2),
                "\R[{};10;6;2;{}]".format(offset, self.fg2),
                "\R[{};6;2;1;{}]".format(offset, self.fg2),
                "\R[{};4;2;8;{}]".format(offset + 6, self.fg2)
            )
        return ""
