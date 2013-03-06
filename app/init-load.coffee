exports.start = ->
	canvas = document.getElementById "shadowPatternCanvas"
	stage = new createjs.Stage canvas

	roguelikebase = {}
	roguelikebase.stage = stage

	manifest = [
		{src:"images/rltiles-dungeon.png", id:"dungeonspritesheet"},
		{src:"images/rltiles-items.png", id:"itemspritesheet"},
		{src:"images/rltiles-monsters.png", id:"monsterspritesheet"},
		{src:"images/rltiles-player.png", id:"playerspritesheet"}
	]

	preload = new createjs.LoadQueue false
	preload.installPlugin createjs.sound

	assets = new Object()
	assets.images = {}
	assets.sounds = {}

	roguelikebase.assets = assets

	loadprocessor = (event) ->
		item = event.item
		if item.type == createjs.LoadQueue.IMAGE
			assets.images[item.id] = event.result
		else if item.type == createjs.LoadQueue.SOUND
			assets.sounds[item.id] = event.result


	preloadcomplete = (event) ->
		# the player spritesheet has multiple images that are typically layered on top of each other such as
		# a body, clothes, sword, etc. so the player spritesheet needs to have a transparent background. But
		# it doesn't by default, so here we create a version with a transparent background
		chromakeymodule = require 'chromakey'
		assets.images["playerspritesheet-alpha"] = chromakeymodule.chromaKeyImage assets.images["playerspritesheet"], [71,108,108]

		dungeonmodule = require 'dungeontilemap'
		playermodule = require 'player'

		stage.removeAllChildren()

		#console.log roguelikebase.assets

		spriteSheet = new createjs.SpriteSheet {images:[assets.images["dungeonspritesheet"]], frames: {width:32, height:32}}

		bmpAnim = new createjs.BitmapAnimation spriteSheet
		bmpAnim.gotoAndStop 30
		bmpAnim.x = 32
		bmpAnim.y = 32

		#stage.addChild bmpAnim

		dungeonwidth = 50
		dungeonheight = 50
		dungeon = dungeonmodule.createDungeonTilemap dungeonwidth, dungeonheight, 32, 32, spriteSheet
		dungeon.x = 0
		dungeon.y = 0
		roguelikebase.dungeon = dungeon

		map = new ROT.Map.Digger dungeonwidth, dungeonheight, {roomWidth:[4,9], roomHeight:[4,9], corridorLength:[4,12], dugPercentage:0.4}
		map.create (x,y,wall) -> dungeon.tiledata[x][y].spriteframe = (if wall > 0 then 13 else 30)

		stage.addChild dungeon

		player = playermodule.createPlayer roguelikebase
		player.x = 128
		player.y = 128
		stage.addChild player

		infotext = new createjs.Text "Argh!\nurgh", "Arial", "#08f"
		stage.addChild infotext

		stage.update()

	loadingtext = new createjs.Text "Loading."
	loadingtext.x = stage.width/2
	loadingtext.y = stage.height/2
	stage.addChild loadingtext
	stage.update()

	preload.addEventListener "progress", (event) ->
		loadingtext.text = loadingtext.text + "."
		stage.update()
		console.log event
	preload.addEventListener "complete", preloadcomplete
	preload.addEventListener "fileload", loadprocessor
	preload.loadManifest manifest

