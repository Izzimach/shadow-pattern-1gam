exports.start = ->
	canvas = document.getElementById "shadowPatternCanvas"

	roguelikebase = {}
	roguelikebase.stage = new createjs.Stage canvas

	roguelikebase.engine = new ROT.Engine()

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
		assets.images["player-alpha"] = chromakeymodule.chromaKeyImage assets.images["playerspritesheet"], [71,108,108]
		assets.images["monsters-alpha"] = chromakeymodule.chromaKeyImage assets.images["monsterspritesheet"], [71,108,108]
		assets.images["items-alpha"] = chromakeymodule.chromaKeyImage assets.images["itemspritesheet"], [71,108,108]

		dungeonmodule = require 'dungeon'
		playermodule = require 'player'

		roguelikebase.stage.removeAllChildren()

		dungeonview = new createjs.Container()
		dungeonview.name = "dungeonview"
		roguelikebase.stage.addChild dungeonview

		dungeon = dungeonmodule.createDungeon roguelikebase
		dungeonmodule.installDungeon roguelikebase, dungeon

		player = playermodule.createPlayer roguelikebase
		roguelikebase.player = player
		playerstarttile = dungeon.upstairstile
		dungeon.addPlayer player, playerstarttile.tilex, playerstarttile.tiley

		Monster = require 'creatures/Monster'
		creaturestats = (require 'creatures/CreatureList').DefaultCreature
		monster = new Monster "bob", creaturestats, roguelikebase
		monsterstarttile = dungeon.pickFloorTile()
		dungeon.addMonster monster, monsterstarttile.tilex, monsterstarttile.tiley

		roguelikebase.messagelog = new createjs.Text "Argh!\nurgh", "Arial", "#08f"
		roguelikebase.messagelog.messages = []
		roguelikebase.messagelog.addMessage = (message) ->
			if @messages.length > 10
				@messages.splice 0,@messages.length-10
			@messages.push message
			@text = @messages.join "\n"
		roguelikebase.stage.addChild roguelikebase.messagelog

		roguelikebase.playerinfo = new createjs.Text "Player Data:", "Arial", "#fff"
		roguelikebase.playerinfo.x = 500
		roguelikebase.stage.addChild roguelikebase.playerinfo

		graphics = new createjs.Graphics().beginFill("#ff0000").drawRect(0, 0, 100, 100);
		roguelikebase.inventory = new createjs.Shape graphics
		roguelikebase.inventory.x = 600
		roguelikebase.inventory.y = 400
		roguelikebase.stage.addChild roguelikebase.inventory

		roguelikebase.stage.update()

		roguelikebase.engine.start()

	addLoadingText = (stage) ->
		loadingtext = new createjs.Text "Loading."
		loadingtext.x = stage.width/2
		loadingtext.y = stage.height/2
		stage.addChild loadingtext
		stage.update()

	addLoadingText roguelikebase.stage

	preload.addEventListener "progress", (event) ->
		loadingtext.text = loadingtext.text + "."
		stage.update()
		console.log event
	preload.addEventListener "complete", preloadcomplete
	preload.addEventListener "fileload", loadprocessor
	preload.loadManifest manifest

