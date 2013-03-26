Creature = require 'creatures/Creature'

module.exports = class Monster extends Creature
	constructor : (basestats, roguelikebase, name=null) ->
		super basestats, roguelikebase, name

	addedToDungeon: (dungeon, x, y) ->
		super dungeon,x,y
		@target = null
		@passableCallback = (x,y) =>
			return true if x == @x and y == @y
			@dungeon.isPassable x,y,true # ignore monsters blocking the path

	act: ->
		if @target
			# pathfind to target
			movepath = []
			pathfinder = new ROT.Path.AStar @target.x,@target.y, @passableCallback
			pathfinder.compute @x,@y, (x,y) -> movepath.push [x,y]
			nexttile = movepath[1]
			#console.log [@x,@y], nexttile
			if nexttile
				[nextx, nexty] = nexttile
				if nextx is @target.x and nexty is @target.y
					@attackTarget @target
				else
					if @dungeon.isPassable nextx,nexty,false
						@moveToTile nextx,nexty
		else
			@target = @roguelikebase.player if @awake

	attackTarget: (target) ->
		damageamount = @target.applyDamage @basestats.basedamage
		message = @name + " attacks " + @target.name + " for " + damageamount + " damage"
		@roguelikebase.messagelog.addMessage message
		if @target.health < 0
			@roguelikebase.messagelog.addMessage @name + " kills " + @target.name + "!"
