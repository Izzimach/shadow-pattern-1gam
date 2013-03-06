
addPlayer = (player, x, y) ->
	@player = player
	player.putInDungeon this, x, y

removePlayer = (player) ->
	@player = null
	player.removeFromDungeon this

addMonster = (monster, x, y) ->
	@monsters.push monster
	monster.putInDungeon this,x,y

removeMonster = (monster) ->
	monsterindex = @monsters.indexOf monster
	@monsters.splice monsterindex, 1
	monster.removeFromDungeon this

exports.createDungeon = (roguelikebase) ->
	tilemapmodule = require 'dungeontilemap'

	spriteSheet = new createjs.SpriteSheet {images:[roguelikebase.assets.images["dungeonspritesheet"]], frames: {width:32, height:32}}

	#stage.addChild bmpAnim

	dungeonwidth = 50
	dungeonheight = 50
	tilewidth = 32
	tileheight = 32
	tilemap = tilemapmodule.createDungeonTilemap dungeonwidth, dungeonheight, tilewidth, tileheight, spriteSheet
	tilemap.x = 0
	tilemap.y = 0

	map = new ROT.Map.Digger dungeonwidth, dungeonheight, {roomWidth:[4,9], roomHeight:[4,9], corridorLength:[4,12], dugPercentage:0.4}
	diggerdatatosprite = (x,y,wall) -> tilemap.tiledata[x][y].spriteframe = (if wall > 0 then 13 else 30)
	map.create diggerdatatosprite

	dungeon = {
		player: null,
		monsters: [],
		items: [],

		dungeonview:null,

		tilewidth: tilewidth,
		tileheight: tileheight
		width:dungeonwidth,
		height:dungeonheight
	}
	dungeon.tilemap = tilemap
	dungeon.addPlayer = addPlayer
	dungeon.addMonster = addMonster
	dungeon.removeMonster = removeMonster
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
	dungeonview.addChild dungeontoinstall.tilemap

	dungeontoinstall.dungeonview = dungeonview

	roguelikebase.dungeon = dungeontoinstall

	return roguelikebase

exports.uninstallCurrentDungeon = uninstallCurrentDungeon
