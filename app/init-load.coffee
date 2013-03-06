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

		dungeonmodule = require 'dungeon'
		playermodule = require 'player'

		stage.removeAllChildren()

		dungeonview = new createjs.Container()
		dungeonview.name = "dungeonview"
		stage.addChild dungeonview

		dungeon = dungeonmodule.createDungeon roguelikebase
		dungeonmodule.installDungeon roguelikebase, dungeon

		player = playermodule.createPlayer roguelikebase
		dungeon.addPlayer player, 4,4

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

