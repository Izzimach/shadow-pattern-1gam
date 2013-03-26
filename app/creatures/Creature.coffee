# base creature class. base stats are:
# -speed
# -visualrange
# -health
# -sprite name (can be an array, in which case one is chosen at random)
MonsterSpriteData = require 'creatures/MonsterSpriteSheet'

module.exports = class Creature
	constructor: (@basestats, @roguelikebase, name) ->
		if name then @name = name else @name = @basestats.defaultname
		@visibletiles = []
		@health = @basestats.health
		@awake = (ROT.RNG.getUniform() < 0.8)
		if basestats.spritename and basestats.spritename in MonsterSpriteData.Names
			@sprite = MonsterSpriteData.createSprite basestats.spritename, roguelikebase

	addedToDungeon: (dungeon, x, y) ->
		@dungeon = dungeon
		if dungeon.dungeonview? and @sprite?
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

	moveToTile : (x,y) ->
		@x = x
		@y = y
		@recomputeVisibility()
		@dungeon.visibilitychanged = true
		if @sprite?
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
		if @dungeon.isPassable newx,newy, false
			@moveToTile newx,newy

	act : ->
		null

	getSpeed: -> @basestats.speed

	applyDamage: (damageamount) ->
		if not @awake
			@awake = true
			@roguelikebase.messagelog.addMessage "#{@name} wakes up!"
		damageamount = damageamount - @basestats.armor
		damageamount = 1 if damageamount < 1
		@health = @health - damageamount
		if @health < 0
			@dungeon.removeCreature this
		return damageamount
