exports.createDungeon = (roguelikebase) ->
	tilemapmodule = require 'dungeontilemap'

	spriteSheet = new createjs.SpriteSheet {images:[roguelikebase.assets.images["dungeonspritesheet"]], frames: {width:32, height:32}}

	#stage.addChild bmpAnim

	dungeonwidth = 20
	dungeonheight = 20
	tilewidth = 32
	tileheight = 32
	tilemap = tilemapmodule.createDungeonTilemap dungeonwidth, dungeonheight, tilewidth, tileheight, spriteSheet
	tilemap.x = 0
	tilemap.y = 0

	map = new ROT.Map.Digger dungeonwidth, dungeonheight, {roomWidth:[4,9], roomHeight:[4,9], corridorLength:[4,12], dugPercentage:0.4}
	diggerdatatosprite = (x,y,wall) -> 
		tile = tilemap.tiledata[x][y]
		tile.settile (if wall > 0 then "wall" else "floor")
	map.create diggerdatatosprite

	dungeon = {
		player: null,
		monsters: [],
		items: [],

		tiles : tilemap,

		dungeonview:null,

		tilewidth: tilewidth,
		tileheight: tileheight,
		width:dungeonwidth,
		height:dungeonheight
	}

	dungeon.addPlayer = (player, x, y) ->
		@player = player
		player.putInDungeon this, x, y

	dungeon.removePlayer = (player) ->
		@player = null
		player.removeFromDungeon this

	dungeon.addMonster = (monster, x, y) ->
		@monsters.push monster
		monster.putInDungeon this,x,y

	dungeon.removeMonster = (monster) ->
		monsterindex = @monsters.indexOf monster
		@monsters.splice monsterindex, 1
		monster.removeFromDungeon this

	dungeon.pickFloorTile = ->
		# start at a random location and scan for the first
		# found floor tile
		startx = Math.floor ROT.RNG.getUniform() * @width
		starty = Math.floor ROT.RNG.getUniform() * @height
		for offsetx in [0..dungeon.width-1]
			for offsety in [0..dungeon.height-1]
				testx = (startx + offsety) % @width
				testy = (starty + offsety) % @height
				if @tiles.tiledata[testx][testy].tiletypename is "floor"
					return @tiles.tiledata[testx][testy]
		# no floor tile found!?!?!?
		return null

	dungeon.placeStairs = ->
		@upstairstile = @pickFloorTile()
		@upstairstile.settile "upstairs"
		@downstairstile = @pickFloorTile()
		@downstairstile.settile "downstairs"

	visibletest = (x,y) -> tilemap.isTileTransparent(x,y)
	FOValgorithm = new ROT.FOV.PreciseShadowcasting visibletest

	dungeon.computeVisibility = (x,y, r) ->
		visibletiles = []
		visibletilefound = (x,y,r,vis) -> visibletiles.push [x,y,vis*100,r]
		FOValgorithm.compute x,y,r, visibletilefound
		return visibletiles

	dungeon.setVisibility = (x) -> tilemap.setVisibility x
	dungeon.markAsExplored = (x) -> tilemap.markAsExplored x
	dungeon.registerLight = (x) -> tilemap.registerLight x
	dungeon.updateLight = (id, x) -> tilemap.updateLight id,x
	dungeon.unregisterLight = (id) -> tilemap.unregisterLight id

	dungeon.placeStairs()

	return dungeon

uninstallCurrentDungeon = (roguelikebase) ->	
	dungeonview = roguelikebase.stage.getChildByName "dungeonview"

	# clear out everything in the dungeon view area
	dungeonview.removeAllChildren()
	#oldtilemap = dungeonview.getChildByName "dungeontilemap"
	#if oldtilemap then dungeonview.removeChild oldtilemap

	roguelikebase.dungeon = null

	return roguelikebase

exports.installDungeon = (roguelikebase, dungeontoinstall) ->
	if roguelikebase.dungeon != null
		uninstallCurrentDungeon roguelikebase

	dungeonview = roguelikebase.stage.getChildByName "dungeonview"
	dungeonview.addChild dungeontoinstall.tiles

	dungeontoinstall.dungeonview = dungeonview

	roguelikebase.dungeon = dungeontoinstall

	return roguelikebase

exports.uninstallCurrentDungeon = uninstallCurrentDungeon