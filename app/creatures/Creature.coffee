# base creature class. base stats are:
# -speed
# -visualrange
# -health
# -sprite name (can be an array, in which case one is chosen at random)
MonsterSpriteData = require 'creatures/MonsterSpriteSheet'

module.exports = class Creature
	constructor: (@name, @basestats, @roguelikebase) ->
		@visibletiles = []
		if basestats.spritename and basestats.spritename in MonsterSpriteData.Names
			@sprite = MonsterSpriteData.createSprite basestats.spritename, roguelikebase

	putInDungeon: (dungeon, x, y) ->
		@dungeon = dungeon
		if dungeon.dungeonview isnt null and @sprite isnt null
			dungeon.dungeonview.addChild @sprite
		# not all monsters have lights
		#@lightID = @dungeon.registerLight []
		@moveToTile x,y

	removeFromDungeon : (dungeon) ->
		if dungeon.dungeonview isnt null and @sprite isnt null
			dungeon.dungeonview.removeChild @sprite

		#@dungeon.unregisterLight @lightID
		#@lightID = -1
		@dungeon = null

	moveToTile : (x,y) ->
		@x = x
		@y = y
		@recomputeVisibility()
		@dungeon.visibilitychanged = true
		if @sprite isnt null
			@sprite.x = x * @dungeon.tilewidth
			@sprite.y = y * @dungeon.tileheight

	recomputeVisibility : () ->
		@visibletiles = @dungeon.computeVisibility @x,@y,

		# only players set dungeon visibility
		#@dungeon.setVisibility visibletiles
		#@dungeon.markAsExplored visibletiles
		#@dungeon.updateLight @lightID,visibletiles

	checkIsVisible : () ->
		currenttile = @dungeon.tiles.tiledata[@x][@y]
		@sprite.visible = currenttile.visible if @sprite isnt null

	step : (dx,dy) ->
		newx = @x + dx
		newy = @y + dy
		if @dungeon.isPassable newx,newy
			@moveToTile newx,newy

	act : ->
		null

	getSpeed: -> 100

