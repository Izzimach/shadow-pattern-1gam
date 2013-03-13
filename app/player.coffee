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

	playerhatgraphic = new PlayerIcon
	playerhatgraphic.setplayericon "horned helmet"
	playerhatgraphic.x = 0
	playerhatgraphic.y = -8

	playershoesgraphic = new PlayerIcon
	playershoesgraphic.setplayericon "red chainmail shoes"
	playershoesgraphic.y = 8

	playerweapon1graphic = new PlayerIcon
	playerweapon1graphic.setplayericon "sword, offhand"
	playerweapon1graphic.x = -8

	playerweapon2graphic = new PlayerIcon
	playerweapon2graphic.setplayericon "sword,offhand"
	playerweapon2graphic.x = 8
	playerweapon2graphic.scaleX = -1
	playerweapon2graphic.visible = false

	compositeplayergraphic = new createjs.Container()
	compositeplayergraphic.addChild playershadowgraphic
	compositeplayergraphic.addChild playercloakgraphic
	compositeplayergraphic.addChild playerbodygraphic
	compositeplayergraphic.addChild playershoesgraphic
	compositeplayergraphic.addChild playerclothesgraphic
	compositeplayergraphic.addChild playerhatgraphic
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
		y:0,
		inventory: [],

		# current wielded items
		weapon: null,
		armor: null,
		hat: null
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
		# return true if the player's turn is over
		newx = @x + dx
		newy = @y + dy
		if @dungeon.isPassable newx,newy, false
			@moveToTile newx,newy
			@setViewCenter newx,newy
			# pick up any items here
			pickupitems = []
			for item in @dungeon.items
				if item.x is newx and item.y is newy
					pickupitems.push item
			for pickupme in pickupitems
				@pickupItem pickupme
			return true
		else
			monster = @dungeon.monsterAt newx,newy
			console.log monster
			if monster
				damageamount = @basestats.basedamage
				if @weapon and @weapon.weapondamage
					damageamount = @weapon.weapondamage
				damageamount = monster.applyDamage damageamount
				roguelikebase.messagelog.addMessage "#{@name} attack #{monster.name} for #{damageamount} damage"
				if monster.health < 0
					roguelikebase.messagelog.addMessage "You have killed #{monster.name}!"
				return true
			else
				roguelikebase.messagelog.addMessage "You run into a wall"
				roguelikebase.stage.update()
				return false # doesn't count as an action

	playerdata.applyDamage = (amount) ->
		# reduce damage by armor provided via items
		if @weapon and @weapon.providesarmor
			amount = amount - @weapon.providesarmor
		if @armor and @armor.providesarmor
			amount = amount - @armor.providesarmor
		if @hat and @hat.providesarmor
			amount = amount - @hat.providesarmor
		if amount < 1
			amount = 1
		@health = @health - amount
		return amount

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
		roguelikebase.stage.update()
		roguelikebase.engine.unlock()

	playerdata.updatePlayerSprite = ->
		if @weapon
			playerweapon1graphic.setplayericon @weapon.spritename
		else
			playerweapon1graphic.visible = false
		# set default clothes as a brown robe if the player isn't wearing armor
		if @armor
			playerclothesgraphic.setplayericon @armor.spritename
		else
			playerclothesgraphic.setplayericon "brown robes"
		if @hat
			playerhatgraphic.setplayericon @hat.spritename
		else
			playerhatgraphic.visible = false

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
	    	if playeraction isnt null and playeraction()
	    		@playerturnover()
	    if evt.ctrlKey and evt.keyCode is 90
        	alert "Ctrl-Z"

	playerdata.pickupItem = (item) ->
		@dungeon.removeItem item
		item.pickedUpBy this
		@inventory.push item
		roguelikebase.messagelog.addMessage "You pick up #{item.name}"
		return true # player's turn is over

	playerdata.updatePlayerSprite()
	return playerdata
