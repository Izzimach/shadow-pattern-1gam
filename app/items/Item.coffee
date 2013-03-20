ItemSpriteData = require 'items/ItemSpriteSheet'

module.exports = class Item
	constructor: (@basestats, @roguelikebase, name=null) ->
		if name then @name = name else @name = @basestats.defaultname
		@dungeon = null
		@owner = null
		@equipped = false
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
		@owner = owner
		@equipped = false
		# enabled double-click action
		@sprite.addEventListener "mousedown", this

	droppedBy : (owner) ->
		@owner = null
		@equipped = false

	equippedBy : (owner) ->
		@owner = owner
		@equipped = true

	unequippedBy: (owner) ->
		@owner = owner
		@equipped = false

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

	handleEvent: (event) ->
		console.log event
		if @owner?
			# equip the item. if it's already equipped, unequip it
			if @equipped
				@owner.unequipItem this
			else
				@owner.equipItem this
