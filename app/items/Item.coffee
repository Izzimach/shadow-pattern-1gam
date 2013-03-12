ItemSpriteData = require 'items/ItemSpriteSheet'

module.exports = class Item
	constructor: (@basestats, @roguelikebase, name=null) ->
		if name then @name = name else name = @basestats.defaultname
		if basestats.spritename and basestats.spritename in ItemSpriteData.Names
			@sprite = ItemSpriteData.createSprite basestats.spritename, roguelikebase

	addedToDungeon: (dungeon, x, y) ->
		@dungeon = dungeon
		if dungeon.dungeonview isnt null and @sprite isnt null
			dungeon.dungeonview.addChild @sprite
		# not all monsters have lights
		#@lightID = @dungeon.registerLight []
		@moveToTile x,y

	removedFromDungeon : (dungeon) ->
		if dungeon.dungeonview isnt null and @sprite isnt null
			dungeon.dungeonview.removeChild @sprite

		#@dungeon.unregisterLight @lightID
		#@lightID = -1
		@dungeon = null

	pickedUpBy : (owner) ->
		null

	droppedBy : (owner) ->
		null

	moveToTile : (x,y) ->
		@x = x
		@y = y
		@dungeon.visibilitychanged = true
		if @sprite isnt null
			@sprite.x = x * @dungeon.tilewidth
			@sprite.y = y * @dungeon.tileheight

	checkIsVisible : () ->
		currenttile = @dungeon.tiles.tiledata[@x][@y]
		@sprite.visible = currenttile.visible if @sprite isnt null
