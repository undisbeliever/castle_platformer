#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vim: set fenc=utf-8 ai ts=4 sw=4 sts=4 et:

"""
Converts a SNES tilemap to 16px metatile struct.
"""

import sys
import os
import struct

N_METATILES = 512

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

        # ::ANNOY using python3.2 cannot struct.iter_unpack
        i = 0
        for d in read_iter(fp, 2):
            t = struct.unpack("<H", d)[0]
            mapData.append(t)
            if t != 0:
                last = i
            i += 1

    # Append extra data
    append = [0] * (N_METATILES * 4 - len(mapData))

    return mapData + append


def write_tiles(fp, mapData, offset):
    for y in range(int(len(mapData) / 64)):
        for x in range(16):
            pos = y * 64 + x * 2 + offset
            fp.write(struct.pack("<H", mapData[pos]))


def main(inName, outName):
    mapData = read_map(inName)

    assert len(mapData) == N_METATILES * 4, "Map too big"

    with open(outName, "wb") as fp:
        write_tiles(fp, mapData, 0)
        write_tiles(fp, mapData, 1)
        write_tiles(fp, mapData, 32)
        write_tiles(fp, mapData, 32 + 1)


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("USAGE: {} infile outfile".format(sys.argv[0]), file=sys.stderr)
    else:
        main(sys.argv[1], sys.argv[2])

