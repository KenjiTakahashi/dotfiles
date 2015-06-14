#!/usr/bin/env python2
# -*- encoding: utf-8 -*-

# Copyright (C) 2015 Vibhav Pant <vibhavp@gmail.com>
# Modified by karol 'Kenji Takahashi' Woźniak
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
import tempfile
from distutils.dir_util import copy_tree

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("config", help="the JSON file you want to use")
    parser.add_argument(
        "-r", "--replace", nargs='?', const=True,
        help="replace files/folders if they already exist",
    )
    args = parser.parse_args()
    js = json.load(open(args.config))

    def aux(src, dest):
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
                # Dead link
                os.remove(dest)
            print("Linking {} -> {}".format(dest, src))
            os.symlink(src, dest)

    for path in js.get("directories", []):
        path = os.path.expanduser(path)
        if not os.path.exists(path):
            print("Creating directory {}".format(path))
            os.makedirs(path)

    for src, dest in js.get("link", {}).iteritems():
        if isinstance(dest, list):
            base = os.path.expanduser(dest[0])
            try:
                os.makedirs(base)
            except os.error:
                pass
            for s, d in dest[1].iteritems():
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
