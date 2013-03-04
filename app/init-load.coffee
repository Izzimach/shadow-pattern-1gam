exports.start = ->
	Crafty.init 800, 600

	Crafty.scene "loading", ->
		images = ["images/rltiles-dungeon.png",
				"images/rltiles-player.png",
				"images/rltiles-items.png",
				"images/rltiles-monsters.png"]
		Crafty.load ["images/rltiles-dungeon.png"], ->
			Crafty.scene "main"

	Crafty.scene "main", ->
		Crafty.sprite 32, "images/rltiles-dungeon.png", { DungeonTile:[0,0]}

		(Crafty.e "2D, DOM, DungeonTile").attr {x:0, y:0, z:1}

	Crafty.scene "loading"