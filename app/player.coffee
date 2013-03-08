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
		sprite: compositeplayergraphic,
		dungeon: null,
		lightID:-1,
		# x and y here are tile coordinates, not pixel coordinates
		x:0,
		y:0
	}

	playerdata.putInDungeon = (dungeon, x, y) ->
		@dungeon = dungeon
		if dungeon.dungeonview isnt null
			dungeon.dungeonview.addChild @sprite	

		@lightID = @dungeon.registerLight []
		@moveToTile x,y

	playerdata.removeFromDungeon = (dungeon) ->
		if dungeon.dungeonview isnt null
			dungeon.dungeonview.removeChild @sprite

		@dungeon.unregisterLight @lightID
		@lightID = -1
		@dungeon = null

	playerdata.moveToTile = (x,y) ->
		@x = x
		@y = y
		@sprite.x = x * @dungeon.tilewidth
		@sprite.y = y * @dungeon.tileheight

	playerdata.recomputeVisibility = () ->
		visibletiles = @dungeon.computeVisibility @x,@y,9
		#console.log visibletiles
		@dungeon.setVisibility visibletiles
		@dungeon.markAsExplored visibletiles
		@dungeon.updateLight @lightID,visibletiles

	playerdata.step = (dx,dy) ->
		newx = @x + dx
		newy = @y + dy
		if @dungeon.isPassable newx,newy
			@moveToTile newx,newy
			@recomputeVisibility()
			roguelikebase.stage.update()

	# initialize keyboard input
	document.onkeydown = (evt) ->
    	#console.log evt
	    evt ||= window.event
	    if evt.keyCode
	    	# process as a keycode
	    	if evt.keyCode is ROT.VK_H
	    		roguelikebase.player.step -1,0
	    	else if evt.keyCode is ROT.VK_L
	    		roguelikebase.player.step 1,0
	    	else if evt.keyCode is ROT.VK_K
	    		roguelikebase.player.step 0,-1
	    	else if evt.keyCode is ROT.VK_J
	    		roguelikebase.player.step 0,1
	    if evt.ctrlKey and evt.keyCode is 90
        	alert "Ctrl-Z"
	
	return playerdata
