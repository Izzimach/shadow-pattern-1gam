# records tile data for the dungeon. This really only
# records data used in rendering, like visibility and light

# spritesheet should be an EaselJS SpriteSheet instance
# solidspriteframes is an array of true/false values that indicate which sprite frames
# are solid. For instance [false,true,true,false] indicates that sprites 0 and 3 are passable
# but sprites 1 and 2 indicate walls

exports.createDungeonTilemap = (dungeonwidth, dungeonheight, tilewidth, tileheight, spritesheet, solidspriteframes) ->
	dungeon = new createjs.DisplayObject()

	createTile = (x,y) ->
		return {
			visible: (y>3),
			explored: (x>3), 
			lightlevel:x+y, 
			spriteframe:18, 
			pixelx: x * tilewidth, 
			pixely: y * tileheight
		}

	createColumn = (x) ->
		(createTile x, tiley-1 for tiley in [1..dungeonheight])

	dungeon.tiledata = (createColumn tilex-1 for tilex in [1..dungeonwidth])

	# given an x, y coordinate, get the tile at that coordinate
	dungeon.lookupTile = (x, y) ->
		return dungeon.tiledata[x][y]

	# apply some function to the tiles specified by an array
	# of elements that specify [x y] coordinates: [[x1,y1], [x2,y2],[x3,y3]]
	dungeon.applyToTiles = (tilelist, applyfunc) ->
		(applyfunc lookupTile t[0],t[1]) for t in tilelist

	dungeon.drawTile = (ctx, tile) ->
		o = spritesheet.getFrame tile.spriteframe
		if o
			rect = o.rect
			ctx.globalAlpha = 1.0
			if tile.visible
				ctx.fillRect tile.pixelx - o.regX, tile.pixely - o.regY, rect.width, rect.height
				if tile.lightlevel >= 75
					ctx.globalAlpha = 1.0
				else
					ctx.globalAlpha = 0.25 + tile.lightlevel/100.0
				ctx.drawImage o.image, rect.x, rect.y, rect.width, rect.height, tile.pixelx - o.regX, tile.pixely - o.regY, rect.width, rect.height
			else if tile.explored
				ctx.fillRect tile.pixelx - o.regX, tile.pixely - o.regY, rect.width, rect.height
				ctx.globalAlpha = 0.25
				ctx.drawImage o.image, rect.x, rect.y, rect.width, rect.height, tile.pixelx - o.regX, tile.pixely - o.regY, rect.width, rect.height				
			else
				ctx.fillRect tile.pixelx - o.regX, tile.pixely - o.regY, rect.width, rect.height

		return true

	dungeon.DisplayObject_draw = dungeon.draw

	dungeon.draw = (ctx, ignoreCache) ->
		if this.DisplayObject_draw ctx, ignoreCache
			return true

		(this.drawTile ctx, t for t in column) for column in this.tiledata

		return true

	dungeon.isVisible = ->
		return this.visible and spritesheet.complete

	visibletiles = []
	
	dungeon.setVisibility = (fresh_visibletiles) ->
		# first reset old visible tiles
		this.applyToTiles visibletiles, (tile) -> tile.visible = false
		this.applyToTiles fresh_visibletiles, (tile) -> tile.visible = true
		visibletiles = fresh_visibletiles

	dungeon.markAsExplored = (exploredtiles) ->
		this.applyToTiles exploredtile, (tile) -> tile.explored = true

	dungeonlights = {}
	nextlightID = 1

	# create a light and set the specified tiles to be lit
	# light data is an array with each element of the form {x,y,l}
	# where x,y are the tile coordinates and l is the light level (0-100)
	dungeon.registerLight = (lightdata) ->
		lightID = nextlightID
		nextlightID = nextlightID + 1
		dungeonlight[nextlightID] = lightdata
		for t in lightdata
			tile = lookupTile t[0],t[1]
			tile.lightlevel = tile.lightlevel + t[2]
		return lightID

	dungeon.updateLight = (lightID, fresh_lightdata) ->
		old_lightdata = dungeonlights[lightID]
		for t in old_lightdata
			old_tile = lookupTile t[0],t[1]
			old_tile.lightlevel = old_tile.lightleve - t[2]
		for t in fresh_lightdata
			fresh_tile = lookupTile t[0],t[1]
			fresh_tile.lightlevel = fresh_tile.lightlevel + t[2]
		dungeonlights[lightID] = fresh_lightdata
		return lightID

	dungeon.unregisterLight = (lightID) ->
		delete dungeonlights[lightID]

	return dungeon
