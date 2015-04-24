#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vim: set fenc=utf-8 ai ts=4 sw=4 sts=4 et:

"""
Converts a SNES tilemap to 16px metatile struct.
"""

import sys
import os
import struct

def read_iter(fp, size):
    while True:
        out = fp.read(size)
        if out:
            yield(out)
        else:
            break

def read_map(filename):
    with open(filename, "rb") as fp:
        mapData = list()
        last = 0

        # ::ANNOY using python3.2 cannot struct.uter_unpack
        i = 0
        for d in read_iter(fp, 2):
            t = struct.unpack("<H", d)[0]
            mapData.append(t)
            if t != 0:
                last = i
            i += 1

    size = int((last - 1) / 64 + 1) * 64

    return mapData[:size]


def main(inName, outName):
    mapData = read_map(inName)

    with open(outName, "wb") as fp:
        for y in range(int(len(mapData) / 64)):
            for x in range(16):
                pos = y * 64 + x * 2
                fp.write(struct.pack("<H", mapData[pos]))
                fp.write(struct.pack("<H", mapData[pos + 1]))
                fp.write(struct.pack("<H", mapData[pos + 32]))
                fp.write(struct.pack("<H", mapData[pos + 32 + 1]))





if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("USAGE: {} infile outfile".format(sys.argv[0]), file=sys.stderr)
    else:
        main(sys.argv[1], sys.argv[2])

