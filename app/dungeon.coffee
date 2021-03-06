exports.createDungeon = (roguelikebase) ->
	tilemapmodule = require 'dungeontilemap'

	spriteSheet = new createjs.SpriteSheet {images:[roguelikebase.assets.images["dungeonspritesheet"]], frames: {width:32, height:32, regX:16, regY:16}}

	#stage.addChild bmpAnim

	dungeonwidth = 30
	dungeonheight = 30
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
		height:dungeonheight,

		visiblitychanged : false
	}

	dungeon.addPlayer = (player, x, y) ->
		if @player isnt null
			@player.removedFromDungeon this
			roguelikebase.engine.removeActor @player
		@player = player
		player.addedToDungeon this, x, y
		roguelikebase.engine.addActor player
		@visiblitychanged = true

	dungeon.removePlayer = (player) ->
		if @player is player
			@player = null
			player.removedFromDungeon this
			roguelikebase.engine.removeActor player
			@visiblitychanged = true

	dungeon.addMonster = (monster, x, y) ->
		if monster not in @monsters
			@monsters.push monster
			monster.addedToDungeon this,x,y
			roguelikebase.engine.addActor monster
			@visiblitychanged = true

	dungeon.removeMonster = (monster) ->
		if monster in @monsters
			monsterindex = @monsters.indexOf monster
			@monsters.splice monsterindex, 1
			monster.removedFromDungeon this
			roguelikebase.engine.removeActor monster
			@visiblitychanged = true

	dungeon.removeCreature = (creature) ->
		if creature is @player
			@removePlayer creature
		else
			@removeMonster creature

	dungeon.addItem = (item, x, y) ->
		if item not in @items
			@items.push item
			item.addedToDungeon this,x,y
			@visibilitychanged = true
	
	dungeon.removeItem = (item) ->
		if item in @items
			itemindex = @items.indexOf item
			@items.splice itemindex,1
			item.removedFromDungeon this
			@visibilitychanged = true

	dungeon.pickFloorTile = ->
		# start at a random location and scan for the first
		# found floor tile
		startx = Math.floor ROT.RNG.getUniform() * @width
		starty = Math.floor ROT.RNG.getUniform() * @height
		for offsetx in [0...dungeon.width]
			for offsety in [0...dungeon.height]
				testx = (startx + offsety) % @width
				testy = (starty + offsety) % @height
				if @tiles.tiledata[testx][testy].passable
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

	dungeon.updateVisibleObjects = ->
		if @visibilitychanged
			# update visibility of monsters
			monster.checkIsVisible() for monster in @monsters
			# update visibility of items
			item.checkIsVisible() for item in @items
			@visibilitychanged = false

	dungeon.setVisibility = (x) ->
		tilemap.setVisibility x
		@visibilitychanged = true

	dungeon.markAsExplored = (x) -> tilemap.markAsExplored x
	dungeon.registerLight = (x) -> tilemap.registerLight x
	dungeon.updateLight = (id, x) -> tilemap.updateLight id,x
	dungeon.unregisterLight = (id) -> tilemap.unregisterLight id

	dungeon.monsterAt = (x,y) ->
		for monster in @monsters
			return monster if monster.x is x and monster.y is y
		null

	dungeon.isPassable = (x,y,ignoremonsters=false) -> (@tiles.isTilePassable x,y) and (ignoremonsters or (@monsterAt x,y) is null)

	#dungeon.placeStairs()

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
