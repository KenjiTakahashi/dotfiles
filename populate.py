#!/usr/bin/env python2
# -*- encoding: utf-8 -*-

# Copyright (C) 2015 Vibhav Pant <vibhavp@gmail.com>
# Modified by Karol 'Kenji Takahashi' Woźniak
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

import argparse
import json
import os
import shutil
import string
import tempfile
from distutils.dir_util import copy_tree


class T(string.Template):
    delimiter = '%%'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("config", help="the JSON file you want to use")
    parser.add_argument(
        "-r", "--replace", nargs='?', const=True,
        help="replace files/folders if they already exist",
    )
    args = parser.parse_args()
    js = json.load(open(args.config))
    vars = js.get("vars", {})

    def aux(src, dest):
        if isinstance(dest, dict):
            templates = dest['templates']
            try:
                for tname, tval in templates.items():
                    templates[tname] = tval.format(**vars)
                with open(src) as f:
                    t = T(f.read())
                with open("{}.fin".format(src), "w") as f:
                    f.write(t.substitute(templates))
            except Exception as e:
                print("Failed to apply template: `{}`".format(e))
                return
            src = "{}.fin".format(src)
            dest = dest['destination']

        src = os.path.abspath(src).encode('utf8')
        dest = os.path.expanduser(dest).encode('utf8')

        if os.path.exists(dest):
            if args.replace is not True and args.replace != os.path.basename(src):
                return
            tempdir = tempfile.mkdtemp()
            if os.path.isfile(dest):
                shutil.copy2(dest, tempdir)
                os.remove(dest)
            else:
                copy_tree(dest, tempdir)
                if os.path.islink(dest):
                    os.remove(dest)
                else:
                    shutil.rmtree(dest)
            print("Linking {} -> {}".format(dest, src))
            try:
                os.makedirs(src)
            except os.error:
                pass
            os.symlink(src, dest)
            if os.path.isdir(dest):
                copy_tree(tempdir, dest)
        else:
            if os.path.islink(dest):
                os.remove(dest)  # Dead link
            print("Linking {} -> {}".format(dest, src))
            os.symlink(src, dest)

    for path in js.get("directories", []):
        path = os.path.expanduser(path)
        if not os.path.exists(path):
            print("Creating directory {}".format(path))
            os.makedirs(path)

    for src, dest in js.get("links", {}).iteritems():
        if isinstance(dest, dict) and 'links' in dest:
            base = os.path.expanduser(dest['destination'])
            try:
                os.makedirs(base)
            except os.error:
                pass
            for s, d in dest['links'].iteritems():
                aux(os.path.join(src, s), os.path.join(base, d))
        else:
            aux(src, dest)

    for src, dest in js.get("copy", {}).iteritems():
        dest = os.path.expanduser(dest).encode('utf8')
        src = os.path.abspath(src).encode('utf8')
        print("Copying {} -> {}".format(src, dest))
        if os.path.exists(dest) and not args.replace:
            continue
        copy_tree(src, dest)

    for command in js.get("commands", []):
        os.system(command)

    print("Done!")

if __name__ == "__main__":
    main()
