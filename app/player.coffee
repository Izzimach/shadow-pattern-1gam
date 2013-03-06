exports.createPlayer = (roguelikebase) ->
	playerframedata = [
		# human bodies
		[0,0,32,32,0,0,0],
		[32,0,32,32,0,0,0],

		# clothes
		[0,128,16,32,0,0,0],
		[16,128,16,32,0,0,0],

		# shoes
		[0,96,32,16,0,0,0],
		[0,112,32,16,0,0,0],

		# weapons
		[0,320,16,32,0,0,0],
		[16,256,16,32,0,0,0],

		# shields/off-hands
		[480,224,16,32,0,0,0],
		[464,224,16,32,0,0,0]
	]

	spriteSheet = new createjs.SpriteSheet {images:[roguelikebase.assets.images["playerspritesheet-alpha"]], frames: playerframedata}

	playerbodygraphic = new createjs.BitmapAnimation spriteSheet
	playerbodygraphic.gotoAndStop 0

	playerclothesgraphic = new createjs.BitmapAnimation spriteSheet
	playerclothesgraphic.gotoAndStop 3
	playerclothesgraphic.x = 8

	playershoesgraphic = new createjs.BitmapAnimation spriteSheet
	playershoesgraphic.gotoAndStop 4
	playershoesgraphic.y = 16

	playerweapon1graphic = new createjs.BitmapAnimation spriteSheet
	playerweapon1graphic.gotoAndStop 6

	playerweapon2graphic = new createjs.BitmapAnimation spriteSheet
	playerweapon2graphic.gotoAndStop 8
	playerweapon2graphic.x = 18

	compositeplayer = new createjs.Container()
	compositeplayer.addChild playerbodygraphic
	compositeplayer.addChild playershoesgraphic
	compositeplayer.addChild playerclothesgraphic
	compositeplayer.addChild playerweapon1graphic
	compositeplayer.addChild playerweapon2graphic


	return compositeplayer
