exports.createPlayer = (roguelikebase) ->
	playerframedata = (require 'playerspritesheet').FrameData

	# we need to build two arrays: one lists all the frame rectangle in order,
	# and the other maps from icon names to frame indices
	playericonnames  = (key for key of playerframedata)
	playerframes = (playerframedata[iconname] for iconname in playericonnames)
	#console.log playericonnames
	#console.log playerframes

	# yucky extending of an easelJS object
	PlayerIcon = ->
		playericon = new createjs.BitmapAnimation spriteSheet
		playericon.setplayericon = (iconname) ->
			@gotoAndStop playericonnames.indexOf(iconname)
		return playericon

	spriteSheet = new createjs.SpriteSheet {images:[roguelikebase.assets.images["player-alpha"]], frames: playerframes}

	playershadowgraphic = new PlayerIcon
	playershadowgraphic.setplayericon "player shadow"

	playercloakgraphic = new PlayerIcon
	playercloakgraphic.setplayericon "red cloak"

	playerbodygraphic = new PlayerIcon
	playerbodygraphic.setplayericon "human1 female"	

	playerclothesgraphic = new PlayerIcon
	playerclothesgraphic.setplayericon "chainmail shirt"
	#playerclothesgraphic.x = 8

	playershoesgraphic = new PlayerIcon
	playershoesgraphic.setplayericon "red chainmail shoes"
	playershoesgraphic.y = 8

	playerweapon1graphic = new PlayerIcon
	playerweapon1graphic.setplayericon "sword, offhand"
	playerweapon1graphic.x = -8

	playerweapon2graphic = new PlayerIcon
	playerweapon2graphic.setplayericon "sword, offhand"
	playerweapon2graphic.x = 8
	playerweapon2graphic.scaleX = -1

	compositeplayergraphic = new createjs.Container()
	compositeplayergraphic.addChild playershadowgraphic
	compositeplayergraphic.addChild playercloakgraphic
	compositeplayergraphic.addChild playerbodygraphic
	compositeplayergraphic.addChild playershoesgraphic
	compositeplayergraphic.addChild playerclothesgraphic
	compositeplayergraphic.addChild playerweapon1graphic
	compositeplayergraphic.addChild playerweapon2graphic

	playerdata = {
		name: "You",
		health: 10,
		sprite: compositeplayergraphic,
		dungeon: null,
		lightID:-1,
		basestats: (require 'creatures/CreatureList').DefaultPlayer,
		# x and y here are tile coordinates, not pixel coordinates
		x:0,
		y:0
	}

	playerdata.addedToDungeon = (dungeon, x, y) ->
		@dungeon = dungeon
		if dungeon.dungeonview isnt null
			dungeon.dungeonview.addChild @sprite	

		@lightID = @dungeon.registerLight []
		@moveToTile x,y
		@setViewCenter x,y

	playerdata.removedFromDungeon = (dungeon) ->
		if dungeon.dungeonview isnt null
			dungeon.dungeonview.removeChild @sprite

		@dungeon.unregisterLight @lightID
		@lightID = -1
		@dungeon = null

	playerdata.moveToTile = (x,y) ->
		@x = x
		@y = y
		@recomputeVisibility()
		@sprite.x = x * @dungeon.tilewidth
		@sprite.y = y * @dungeon.tileheight

	playerdata.recomputeVisibility = () ->
		visibletiles = @dungeon.computeVisibility @x,@y,5
		#console.log visibletiles
		@dungeon.setVisibility visibletiles
		@dungeon.markAsExplored visibletiles
		@dungeon.updateLight @lightID,visibletiles

	playerdata.setViewCenter = (viewtilex, viewtiley) ->
		stagecenterx = roguelikebase.stage.canvas.width/2
		stagecentery = roguelikebase.stage.canvas.height/2
		dungeonview = roguelikebase.stage.getChildByName "dungeonview"
		viewpixelx = viewtilex * @dungeon.tilewidth
		viewpixely = viewtiley * @dungeon.tileheight
		dungeonscrollX = stagecenterx - viewpixelx
		dungeonscrollY = stagecentery - viewpixely
		dungeonview.x = dungeonscrollX
		dungeonview.y = dungeonscrollY

	playerdata.step = (dx,dy) ->
		newx = @x + dx
		newy = @y + dy
		if @dungeon.isPassable newx,newy, false
			@moveToTile newx,newy
			@setViewCenter newx,newy
			roguelikebase.stage.update()
		else
			monster = @dungeon.monsterAt newx,newy
			console.log monster
			if monster
				roguelikebase.messagelog.addMessage @name + " attack " + monster.name
				monster.applyDamage @basestats.basedamage
				if monster.health < 0
					roguelikebase.messagelog.addMessage "You have killed " + monster.name + "!"
			else
				roguelikebase.messagelog.addMessage "You run into a wall"

	playerdata.applyDamage = (amount) ->
		@health = @health - amount

	# for ROT.engine and ROT.scheduler
	playerdata.getSpeed = -> 100; # standard actor speed

	playerdata.act = ->
		# halt the engine, and wait for keyboard input
		roguelikebase.engine.lock()
		@dungeon.updateVisibleObjects()
		roguelikebase.stage.update()
		window.addEventListener "keydown", this

	playerdata.playerturnover = ->
		window.removeEventListener "keydown", this
		roguelikebase.engine.unlock()

	# initialize keyboard input
	playerdata.handleEvent = (evt) ->
    	#console.log evt
	    evt ||= window.event
	    playeraction = null
	    if evt.keyCode
	    	# process as a keycode
	    	# left/right/up/down
	    	if evt.keyCode is ROT.VK_H
	    		playeraction = -> playerdata.step -1,0
	    	else if evt.keyCode is ROT.VK_L
	    		playeraction = -> playerdata.step 1,0
	    	else if evt.keyCode is ROT.VK_K
	    		playeraction = -> playerdata.step 0,-1
	    	else if evt.keyCode is ROT.VK_J
	    		playeraction = -> playerdata.step 0,1
	    	# diagonals
	    	else if evt.keyCode is ROT.VK_Y
	    		playeraction = -> playerdata.step -1,-1
	    	else if evt.keyCode is ROT.VK_U
	    		playeraction = -> playerdata.step 1,-1
	    	else if evt.keyCode is ROT.VK_B
	    		playeraction = -> playerdata.step -1,1
	    	else if evt.keyCode is ROT.VK_N
	    		playeraction = -> playerdata.step 1,1
	    	if playeraction isnt null
	    		playeraction()
	    		@playerturnover()
	    if evt.ctrlKey and evt.keyCode is 90
        	alert "Ctrl-Z"
	
	return playerdata
