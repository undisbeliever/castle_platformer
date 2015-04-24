#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vim: set fenc=utf-8 ai ts=4 sw=4 sts=4 et:

"""
Converts the tmx file to a single layer 16px metamap.

DataPrefix:
    uint16  widthPx
    uint16  heightPx
    byte    dataFormat

UncompressedData:
    uint16  size
    .word   (tile * 8)

"""

import tmx
import sys
import os
import struct

SIZEOF_METATILE_STRUCT = 8


def main(inName, outName):
    map = tmx.TileMap.load(inName)

    assert map.tilewidth == 16, "Tile width must be 16"
    assert map.tileheight == 16, "Tile height must be 16"
    assert map.width * map.tilewidth % 256 == 0, "Map width must be a multiple of 256"
    assert map.renderorder == "right-down", "Map Render Order must be right-down."
    assert len(map.tilesets) == 1, "Only one tileset is accepted"
    assert len(map.layers) == 1, "Only one layer is accepted"

    gidOffset = map.tilesets[0].firstgid
    tiles = map.layers[0].tiles

    with open(outName, "wb") as of:
        of.write(struct.pack('<H', map.width * map.tilewidth))
        of.write(struct.pack('<H', map.height * map.tileheight))
        # ::DEBUG Currently only support uncompressed data::
        of.write(struct.pack('<B', 0))

        of.write(struct.pack('<H', len(tiles) * 2))

        for t in tiles:
            assert t.hflip == False, "Doesn't support tile flipping"
            assert t.vflip == False, "Doesn't support tile flipping"
            assert t.dflip == False, "Doesn't support tile flipping"

            a = (t.gid - gidOffset) * SIZEOF_METATILE_STRUCT
            if a < 0:
                a = 0
            of.write(struct.pack('<H', a))


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("USAGE: {} infile outfile".format(sys.argv[0]), file=sys.stderr)
    else:
        main(sys.argv[1], sys.argv[2])

