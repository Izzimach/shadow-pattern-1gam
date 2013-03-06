exports.start = ->
	canvas = document.getElementById "shadowPatternCanvas"
	stage = new createjs.Stage canvas

	roguelikebase = {}
	roguelikebase.stage = stage

	img = new Image()
	img.src =  "images/rltiles-dungeon.png"
	img.onload = (event) ->
		dungeonmodule = require 'dungeontilemap'

		spriteSheet = new createjs.SpriteSheet {images:[img], frames: {width:32, height:32}}

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

		map = new ROT.Map.Digger dungeonwidth, dungeonheight, {roomWidth:[4,9], roomHeight:[4,9], corridorLength:[4,12], dugPercentage:0.4}
		map.create (x,y,wall) -> dungeon.tiledata[x][y].spriteframe = (if wall > 0 then 13 else 30)

		stage.addChild dungeon

		stage.update()

		infotext = new createjs.Text "Argh!\nurgh", "Arial", "#08f"
		stage.addChild infotext

		stage.update()