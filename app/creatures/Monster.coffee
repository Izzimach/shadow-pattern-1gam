Creature = require 'creatures/Creature'

module.exports = class Monster extends Creature
	constructor : (name, basestats, roguelikebase) ->
		super name, basestats, roguelikebase

	putInDungeon: (dungeon, x, y) ->
		super dungeon,x,y
		@target = null
		@passableCallback = (x,y) =>
			true if x == @x and y == @y
			@dungeon.isPassable x,y,true # ignore monsters blocking the path

	act: ->
		if @target
			# pathfind to target
			movepath = []
			pathfinder = new ROT.Path.AStar @target.x,@target.y, @passableCallback
			pathfinder.compute @x,@y, (x,y) -> movepath.push [x,y]
			nexttile = movepath[1]
			console.log [@x,@y], nexttile
			if nexttile
				[nextx, nexty] = nexttile
				if nextx is @target.x and nexty is @target.y
					@attackTarget @target
				else
					@moveToTile nextx,nexty
		else
			@target = @roguelikebase.player

	attackTarget: (target) ->
		console.log @name, "attacks", @target.name
