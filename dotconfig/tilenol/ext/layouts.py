# -*- coding: utf-8 -*-


from tilenol.layout.tile import Stack, Split, TileStack


class Tile50(Split):
    class Left(Stack):
        weight = 1
        priority = 0
        limit = 1

    class Right(TileStack):
        pass
