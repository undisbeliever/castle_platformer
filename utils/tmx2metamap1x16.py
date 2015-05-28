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
    .word   (tileId * 2)

"""

import tmx
import sys
import os
import os.path
import struct

METATILES_MAP_TILE_ALLOCATION = 80 * 80
TILE_MULTIPLIER = 2
N_METATILES = 512
N_NPCS = 64
TILE_SIZE = 16

def process_tiles(map, layer):
    gidOffset = map.tilesets[0].firstgid
    tiles = layer.tiles
    ret = list()

    for t in tiles:
        assert t.hflip == False, "Doesn't support tile flipping"
        assert t.vflip == False, "Doesn't support tile flipping"
        assert t.dflip == False, "Doesn't support tile flipping"

        a = (t.gid - gidOffset)
        assert a < N_METATILES, "Tile number must be below N_METATILES"
        if a < 0:
            a = 0
        ret.append(a * TILE_MULTIPLIER)

    return ret


def process_targets(map, objlayer):
    ret = dict()

    for o in objlayer.objects:
        assert o.name, "Target must have a name"
        assert o.name not in ret, "Target {} already exists".format(o.name)

        tile = int(o.y / TILE_SIZE) * map.width + int(o.x / TILE_SIZE)
        tile_br = int((o.y + o.height - 1) / TILE_SIZE) * map.width + int((o.x + o.width - 1) / TILE_SIZE)

        assert tile == tile_br, "Target {} must only affect 1 tile".format(o.name)

        ret[o.name] = tile * TILE_MULTIPLIER

    return ret


def process_standing_events(map, objlayer):
    ret = list()

    for o in objlayer.objects:
        assert o.type, "Standing Event must have a type"

        min_tile = int(o.y / TILE_SIZE) * map.width + int(o.x / TILE_SIZE)
        max_tile = int((o.y + o.height - 1) / TILE_SIZE) * map.width + int((o.x + o.width - 1) / TILE_SIZE)

        assert max_tile < min_tile + map.width, "Standing Event {} can only affect 1 row".format(o.type)

        event = {
            'min_tile': min_tile * TILE_MULTIPLIER,
            'max_tile': max_tile * TILE_MULTIPLIER,
            'command': o.type,
            'parameter': 0,
            'name': o.name,
        }

        for p in o.properties:
            if p.name.lower() == 'target':
                event['target'] = p.value
            elif p.name.lower() == 'parameter':
                event['parameter'] = p.value

        ret.append(event)

    return ret


def process_entities(map, objlayer):
    ret = list()

    for o in objlayer.objects:
        assert o.type, "Entity must have a type"

        min_tile = int(o.y / TILE_SIZE) * map.width + int(o.x / TILE_SIZE)
        max_tile = int((o.y + o.height - 1) / TILE_SIZE) * map.width + int((o.x + o.width - 1) / TILE_SIZE)

        entity = {
            'x': int(o.x + o.width / 2),
            'y': int(o.y + o.height / 2),
            'type': o.type,
            'parameter': 0,
            'name': o.name,
        }

        for p in o.properties:
            if p.name.lower() == 'parameter':
                entity['parameter'] = p.value

        ret.append(entity)

    return ret



def write_uncompressed_map(map_fname, map, tiles):
    with open(map_fname, "wb") as of:
        of.write(struct.pack('<H', map.width * map.tilewidth))
        of.write(struct.pack('<H', map.height * map.tileheight))
        # ::DEBUG Currently only support uncompressed data::
        of.write(struct.pack('<B', 0))

        of.write(struct.pack('<H', len(tiles) * 2))

        for t in tiles:
            of.write(struct.pack('<H', t))


def write_properties(filename, map, properties, entities, standing_events, targets):
    with open(filename, "w") as of:

        def writeln(s):
            of.write(s)
            of.write("\n")

        assert 'xpos' in properties, "Expected xpos property in map"
        assert 'ypos' in properties, "Expected ypos property in map"

        writeln("""
.proc MapProperties_{name}

.segment MAP_PROPERTIES_BANK

    .byte   MetatileSetId::{tileset}
    .word   {xPos}
    .word   {yPos}
    .addr   EntitiesTable
    .word   {entities_count}
    .addr   StandingEventsTable
    .word   {standing_events_count}
        """.format(
                name = os.path.splitext(os.path.basename(filename))[0],
                tileset = map.tilesets[0].name.upper(),
                xPos = properties['xpos'],
                yPos = properties['ypos'],
                entities_count = len(entities),
                standing_events_count = len(standing_events),
        ))


        writeln(".segment MAP_ENTITIES_TABLE_BANK")
        writeln("EntitiesTable:")

        for e in entities:
            if e['name'].lower() == "player":
                player = e

        assert player, "Expected an entity named player"

        writeln("\t.word {x}, {y}, {parameter}, .loword(Entity_{type}) ; Player".format(**player))

        npcs = entities[:]
        npcs.remove(player)

        assert len(npcs) <= N_NPCS, "Too many NPCs"

        for n in npcs:
            if n['name']:
                after = " ; {}".format(n['name'])
            else:
                after = ""

            writeln("\t.word {x}, {y}, {parameter}, .loword(Entity_{type}){after}".format(after=after, **n))


        writeln("")
        writeln(".segment STANDING_EVENTS_TABLE_BANK")
        writeln("StandingEventsTable:")

        for e in standing_events:
            if e['name']:
                after = " ; {}".format(e['name'])
            else:
                after = ""

            if e.get('target'):
                assert targets[e['target']], "Target {} does not exist".format(e['target'])
                e['parameter'] = targets[e['target']]

            writeln("\t.word {min_tile}, {max_tile}, StandingEventsCommand::{command}, {parameter}{after}".format(after=after, **e))

        writeln("")
        writeln(".endproc\n")



def main(inName, map_fname, property_fname):
    tiles = None
    targets = dict()
    standing_events = list()
    entities = list()

    map = tmx.TileMap.load(inName)

    assert map.tilewidth == TILE_SIZE, "Tile width must be {}".format(TILE_SIZE)
    assert map.tileheight == TILE_SIZE, "Tile height must be {}".format(TILE_SIZE)
    assert map.renderorder == "right-down", "Map Render Order must be right-down."
    assert len(map.tilesets) == 1, "Only one tileset is accepted"
    assert map.width * map.height <= METATILES_MAP_TILE_ALLOCATION, "Map too large. Must be < {} squares".format(METATILES_MAP_TILE_ALLOCATION)

    for layer in map.layers:
        if type(layer) == tmx.Layer:
            assert tiles == None, "Only one tile layer is allowed"
            tiles = process_tiles(map, layer)

        elif type(layer) == tmx.ObjectGroup:
            if layer.name.lower() == "targets":
                assert len(targets) == 0, "Only one layer can be named Targets"
                targets = process_targets(map, layer)

            elif layer.name.lower() == "standingevents":
                assert len(standing_events) == 0, "Only one layer can be named StandingEvents"
                standing_events = process_standing_events(map, layer)

            elif layer.name.lower() == "entities":
                assert len(entities) == 0, "Only one layer can be named Entities"
                entities = process_entities(map, layer)

            else:
                raise KeyError("Unknown type of layer ", layer.name)
        else:
            raise TypeError("Unable to process layer", layer)

    assert tiles, "There must be a tile layer"

    properties = dict((p.name.lower(), p.value) for p in map.properties)

    write_uncompressed_map(map_fname, map, tiles)
    write_properties(property_fname, map, properties, entities, standing_events, targets)



if __name__ == '__main__':
    if len(sys.argv) != 4:
        print("USAGE: {} <infile> <metamap1x16 out> <inc out>".format(sys.argv[0]), file=sys.stderr)
    else:
        main(sys.argv[1], sys.argv[2], sys.argv[3])


