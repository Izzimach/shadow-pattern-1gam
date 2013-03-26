dungeonmodule = require 'dungeon'
playermodule = require 'player/player'
Monster = require 'creatures/Monster'
CreatureList = require 'creatures/CreatureList'
Item = require 'items/Item'
ItemList = require 'items/ItemList'



module.exports = class ShadowPatternInstance
	constructor: (@roguelikebase) ->
		@roguelikebase.gameinstance = this
		@roguelikebase.stage.removeAllChildren()

		dungeonview = new createjs.Container()
		dungeonview.name = "dungeonview"
		@roguelikebase.stage.addChild dungeonview

		@roguelikebase.engine = new ROT.Engine()
		
		player = playermodule.createPlayer roguelikebase
		@roguelikebase.player = player

		@nextDungeon()

		@roguelikebase.messagelog = new createjs.Text "Welcome to Shadow Pattern!", "15px Arial", "#ddd"
		@roguelikebase.messagelog.lineHeight = 14 #roguelikebase.messagelog.getMeasuredHeight()
		@roguelikebase.messagelog.messages = []
		@roguelikebase.messagelog.x = 200
		@roguelikebase.messagelog.addMessage = (message) ->
			if @messages.length > 10
				@messages.splice 0,@messages.length-10
			@messages.push message
			@text = @messages.join "\n"
		@roguelikebase.stage.addChild roguelikebase.messagelog

		return this

	gameOver: (winninged) ->
		gameoverwindow = new createjs.Container
		gameoverwindow.x = @roguelikebase.stage.canvas.width/2
		gameoverwindow.y = @roguelikebase.stage.canvas.height/2

		if winninged
			gameovertext = "You Win!"
		else
			gameovertext = "You have died."

		gameovertext = new createjs.Text gameovertext, "bold 40px Arial", "#fff"
		gameovertext.textAlign = "center"
		gameovertext.shadow = new createjs.Shadow "#000",5,5,10
		gameovertext.x = 0 # @roguelikebase.stage.canvas.width/2
		gameovertext.y = -100 # @roguelikebase.stage.canvas.height/2
		gameoverwindow.addChild gameovertext

		buttonwidth = 200
		buttonheight = 100
		playagainbutton = new createjs.Shape()
		playagainbutton.graphics.beginFill "#303030"
		playagainbutton.graphics.drawRect -buttonwidth/2,-buttonheight/2, buttonwidth, buttonheight
		playagainbutton.addEventListener "click", => @roguelikebase.startGame()

		gameoverwindow.addChild playagainbutton

		playagaintext = new createjs.Text "Click here to restart", "Arial", "#a0a0a0"
		playagaintext.textAlign = "center"
		gameoverwindow.addChild playagaintext

		@roguelikebase.stage.addChild gameoverwindow

		@roguelikebase.stage.update()

	nextDungeon: ->
		if @roguelikebase.dungeon? and @roguelikebase.player?
			@roguelikebase.dungeon.removePlayer @roguelikebase.player

		@roguelikebase.engine.clear()
		@phasespeed = 3
		@roguelikebase.engine.addActor this

		dungeon = dungeonmodule.createDungeon @roguelikebase
		dungeonmodule.installDungeon @roguelikebase, dungeon

		playerstarttile = dungeon.pickFloorTile()
		dungeon.addPlayer @roguelikebase.player, playerstarttile.tilex, playerstarttile.tiley

		effectivelevel = @roguelikebase.player.effectiveLevel()

		creatures = (require 'creatures/CreatureList').allCreatures
		firstlevelcreatures = (creature for creature in creatures when creature.level <= effectivelevel)
		for multi in [1..2]
			creaturestats = firstlevelcreatures[Math.floor(Math.random() * firstlevelcreatures.length)]
			somemonster = new Monster creaturestats, @roguelikebase
			monsterstarttile = dungeon.pickFloorTile()
			dungeon.addMonster somemonster, monsterstarttile.tilex, monsterstarttile.tiley

		items = (require 'items/ItemList').allItems
		firstlevelitems = (item for item in items when item.level <= effectivelevel)
		for multi in [0...10]
			itemstats = firstlevelitems[Math.floor(Math.random() * firstlevelitems.length)]
			someitem = new Item itemstats, @roguelikebase
			itemstarttile = dungeon.pickFloorTile()
			dungeon.addItem someitem, itemstarttile.tilex, itemstarttile.tiley

		# add the wizard if the player level is high enough
		if effectivelevel >= 7
			wizardstarttile = dungeon.pickFloorTile()
			wizardstats = (require 'creatures/CreatureList').wizard
			wizard = new Monster wizardstats, @roguelikebase
			wizard.awake = true
			dungeon.addMonster wizard, wizardstarttile.tilex, wizardstarttile.tiley
			@roguelikebase.messagelog.addMessage "Beware! The evil wizard is on this level!"

		return dungeon


	# shadow pattern events happen every so often, and accelerate as the player progresses

	getSpeed: -> @phasespeed

	act: ->
		# create a new room?
		@tryToCreateRoom()
		@phasespeed = @phasespeed + 1 if @phasespeed < 10

	tryToCreateRoom : ->
		phasearea = @pickPhaseInArea()
		if phasearea isnt null
			effectivelevel = @roguelikebase.player.effectiveLevel()
			@createRoom phasearea, effectivelevel
			@roguelikebase.messagelog.addMessage @pickMessageForPhasing effectivelevel

	createRoom : (phasearea, level) ->
		[x,y,w,h] = phasearea
		[floortile, walltile] = @pickTilesForRoom level
		@fillTiles x,y,w,h,walltile
		@fillTiles x+1,y+1,w-2,h-2,floortile
		if @phasespeed is 10
			# add downward stairs
			stairtile = @pickOpenTileInArea phasearea
			stairtile.settile "downstairs"
		@connectAreaToDungeon phasearea,floortile,walltile
		@wipeMonstersInArea phasearea
		@wipeItemsInArea phasearea
		@addItemsToArea phasearea,level
		@addMonstersToArea phasearea,level


	pickTilesForRoom : (level) ->
		switch Math.floor(level)
			when 0,1 then ["floor", "wall"]
			when 2,3 then  ["floor", "darkerwall"]
			when 4,5 then  ["flamefloor", "flamewall"]
			when 6,7 then  ["icefloor", "icewall"]
			when 8 then  ["steelfloor", "gemwall"]
			else ["floor","wall"]

	pickMessageForPhasing: (level) ->
		switch Math.floor(level)
			when 0,1 then "You hear the sound of rock and stone shifting."
			when 2,3 then "You feel shadows moving and shifting in the surrounding stone."
			when 4,5 then "You feel a sudden hot draft."
			when 6,7 then "You feel a cold breeze blowing past."
			when 8 then "You hear sharp clanging noises."

	pickPhaseInArea : ->
		dungeon = @roguelikebase.dungeon
		areawidth = Math.floor(Math.random() * 5 + 5)
		areaheight = Math.floor(Math.random() * 5 + 5)
		x = Math.floor(Math.random() * (dungeon.width - areawidth))
		y = Math.floor(Math.random() * (dungeon.height - areaheight))

		# make sure it doesn't overlap the visible area
		visibletiles = dungeon.tiles.visibletiles
		firstx = visibletiles[0][0]
		firsty = visibletiles[0][1]
		visibleminx = visibletiles.reduce ((a,b) -> Math.min(a,b[0])), firstx
		visiblemaxx = visibletiles.reduce ((a,b) -> Math.max(a,b[0])), firstx
		visibleminy = visibletiles.reduce ((a,b) -> Math.min(a,b[1])), firsty
		visiblemaxy = visibletiles.reduce ((a,b) -> Math.max(a,b[1])), firsty

		#console.log visibletiles
		#console.log [x,y,areawidth,areaheight]
		#console.log [visibleminx, visibleminy, visiblemaxx, visiblemaxy]

		if (visibleminx > x+areawidth) or (visiblemaxx < x) or (visibleminy > y+areaheight) or (visiblemaxy < y)
			# no overlap
			return [x,y,areawidth,areaheight]

		# overlap, return null
		return null

	fillTiles : (x,y,w,h, tileset) ->
		tiles = @roguelikebase.dungeon.tiles
		for putx in [x...x+w]
			for puty in [y...y+h]
				curtile = tiles.tiledata[putx][puty]
				curtile.settile tileset
				curtile.explored = false

	isTileInArea : (phasearea, tilex, tiley) ->
		[x,y,w,h] = phasearea
		return (tilex >=x and tilex < x+w and tiley >=y and tiley < y+h)


	wipeMonstersInArea : (phasearea) ->
		dungeon = @roguelikebase.dungeon
		monsters = dungeon.monsters
		monsterstowipe = (m for m in monsters when @isTileInArea phasearea,m.x,m.y)
		for m in monsterstowipe
			# don't delete the wizard!
			if m.name isnt "The Evil Wizard"
				dungeon.removeMonster m

	wipeItemsInArea:  (phasearea) ->
		dungeon = @roguelikebase.dungeon
		items = dungeon.items
		itemstowipe = (i for i in items when @isTileInArea phasearea,i.x,i.y)
		for i in itemstowipe
			dungeon.removeItem i

	addItemsToArea: (phasearea,level) ->
		itemlist = ItemList.allItems
		for multiadd in [0...3]
			itemstats = itemlist[Math.floor(ROT.RNG.getUniform()*itemlist.length)]
			leveldelta = Math.abs(itemstats.level - level)
			if (leveldelta < 1) or ((leveldelta <2) and (Math.random() < 0.2))
				opentile = @pickOpenTileInArea phasearea
				if opentile?
					freshitem = new Item itemstats, @roguelikebase
					@roguelikebase.dungeon.addItem freshitem, opentile.tilex, opentile.tiley

	addMonstersToArea: (phasearea,level) ->
		monsterlist = CreatureList.allCreatures
		for multiadd in [0...3]
			monsterstats = monsterlist[Math.floor(Math.random() * monsterlist.length)]
			leveldelta = Math.abs(monsterstats.level - level)
			# only allow monsters at the right level, sometimes allow monsters near in level
			if (leveldelta < 1) or ((leveldelta < 2) and (Math.random() < 0.2))
				# add monster
				opentile = @pickOpenTileInArea phasearea
				if opentile?
					freshmonster = new Monster monsterstats, @roguelikebase
					@roguelikebase.dungeon.addMonster freshmonster, opentile.tilex, opentile.tiley

	pickOpenTileInArea : (phasearea) ->
		[x,y,w,h] = phasearea
		dungeon = @roguelikebase.dungeon
		dungeontiles = dungeon.tiles
		# start at a random location and scan for the first
		# found floor tile
		startx = Math.floor ROT.RNG.getUniform() * w
		starty = Math.floor ROT.RNG.getUniform() * h
		for offsetx in [0...w]
			for offsety in [0...h]
				testx = (startx + offsety) % w
				testy = (starty + offsety) % h
				finalx = x + testx
				finaly = y + testy
				if dungeontiles.tiledata[finalx][finaly].passable
					return dungeontiles.tiledata[finalx][finaly]
		# no floor tile found!?!?!?
		return null

	connectAreaToDungeon: (phasearea, floortile, walltile) ->
		# connect up multiple passages
		for multi in [0..3]
			connecttotile = @pickTileConnectedToPlayer()
			starttile = @pickOpenTileInArea phasearea
			@buildHallway starttile, connecttotile, floortile, walltile

	pickTileConnectedToPlayer : ->
		dungeon = @roguelikebase.dungeon
		# randomly try open tiles until we find one that can reach the player
		testtile = dungeon.pickFloorTile()
		while not @canReachTile testtile
			testtile = dungeon.pickFloorTile()
		return testtile

	canReachTile: (testtile) ->
		return false if testtile is null
		player = @roguelikebase.player
		pathtiles = []
		passableCallback = (x,y) => @roguelikebase.dungeon.isPassable x,y,true # ignore monsters blocking the path
		pathfinder = new ROT.Path.AStar player.x,player.y, passableCallback
		pathfinder.compute testtile.tilex, testtile.tiley, (x,y) -> pathtiles.push [x,y]
		# if there is a path in pathtiles then the square is reachable
		return (pathtiles.length > 0)

	buildHallway: (starttile, endtile, floortiletype, walltiletype) ->
		startx = starttile.tilex
		starty = starttile.tiley
		endx = endtile.tilex
		endy = endtile.tiley
		# generate an array of [x,y] coordinates that describe the hallway path
		hallwaytiles = [ [startx,starty] ]
		while startx isnt endx or starty isnt endy
			if startx < endx then startx = startx + 1
			else if startx > endx then startx = startx - 1
			else if starty < endy then starty = starty + 1
			else if starty > endy then starty = starty - 1
			hallwaytiles.push [startx,starty]
		# now the path is determined. first lay out the walls. We skip
		# the first and last tile
		if hallwaytiles.length > 2
			for tileindex in [1...hallwaytiles.length-1]
				tile = hallwaytiles[tileindex]
				@putHallwayWalls tile[0], tile[1], walltiletype
		for tilecoords in hallwaytiles
			tile = @roguelikebase.dungeon.tiles.tiledata[tilecoords[0]][tilecoords[1]]
			tile.settile floortiletype
			tile.explored = false

	putHallwayWalls: (x,y, walltiletype) ->
		dungeontiledata = @roguelikebase.dungeon.tiles.tiledata
		for dx in [-1..1]
			for dy in [-1..1]
				tile = dungeontiledata[x+dx][y+dy]
				# replace only walls with the new wall type
				tile.settile walltiletype unless tile.passable
				tile.explored = false








