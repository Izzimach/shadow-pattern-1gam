exports.createPlayer = (roguelikebase) ->
	playerframedata = {
		# human bodies
		"human1 female" : [0,0,32,32,0,0,0],
		"human1 male" : [32,0,32,32,0,0,0],

		# clothes
		"yellow robes" : [0,128,16,32,0,0,0],
		"brown robes" : [16,128,16,32,0,0,0],

		# shoes
		"red shoes" : [0,96,32,16,0,0,0],
		"red chainmail shoes" : [0,112,32,16,0,0,0],

		# weapons
		"battleaxe" : [0,320,16,32,0,0,0],
		"black sword" : [16,256,16,32,0,0,0],

		# shields/off-hands
		"sword, offhand" : [480,224,16,32,0,0,0],
		"sai, offhand" : [464,224,16,32,0,0,0]
	}

	# we need to build two arrays: one lists all the frame rectangle in order,
	# and the other maps from icon names to frame indices
	playericonnames  = (key for key of playerframedata)
	playerframes = (playerframedata[iconname] for iconname in playericonnames)
	#console.log playericonnames
	#console.log playerframes

	# yucky extending of an easelJS object
	PlayerIcon = ->
		playericon = new createjs.BitmapAnimation spriteSheet
		playericon.setplayericon = (iconname) ->
			@gotoAndStop playericonnames.indexOf(iconname)
		return playericon

	spriteSheet = new createjs.SpriteSheet {images:[roguelikebase.assets.images["playerspritesheet-alpha"]], frames: playerframes}

	playerbodygraphic = new PlayerIcon
	playerbodygraphic.setplayericon "human1 female"	

	playerclothesgraphic = new PlayerIcon
	playerclothesgraphic.setplayericon "brown robes"
	playerclothesgraphic.x = 8

	playershoesgraphic = new PlayerIcon
	playershoesgraphic.setplayericon "red shoes"
	playershoesgraphic.y = 16

	playerweapon1graphic = new PlayerIcon
	playerweapon1graphic.setplayericon "battleaxe"

	playerweapon2graphic = new PlayerIcon
	playerweapon2graphic.setplayericon "sword, offhand"
	playerweapon2graphic.x = 18

	compositeplayergraphic = new createjs.Container()
	compositeplayergraphic.addChild playerbodygraphic
	compositeplayergraphic.addChild playershoesgraphic
	compositeplayergraphic.addChild playerclothesgraphic
	compositeplayergraphic.addChild playerweapon1graphic
	compositeplayergraphic.addChild playerweapon2graphic

	playerdata = {
		sprite: compositeplayergraphic,
		dungeon: null,
		x:0,
		y:0
	}

	playerdata.putInDungeon = (dungeon, x, y) ->
		@dungeon = dungeon
		if dungeon.dungeonview != null
			dungeon.dungeonview.addChild @sprite	

		@moveToTile x,y

	playerdata.removeFromDungeon = (dungeon) ->
		@dungeon = null
		if dungeon.dungeonview != null
			dungeon.dungeonview.removeChild @sprite

	playerdata.moveToTile = (x,y) ->
		@x = x
		@y = y
		@sprite.x = x * @dungeon.tilewidth
		@sprite.y = y * @dungeon.tileheight

	return playerdata
