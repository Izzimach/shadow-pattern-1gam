InventoryDisplay = require 'player/InventoryDisplay'
PlayerInfoDisplay = require 'player/PlayerInfoDisplay'
CreatureList = require 'creatures/CreatureList'

exports.createPlayer = (roguelikebase) ->
	playerframedata = (require 'player/playerspritesheet').FrameData

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
	playercloakgraphic.visible = false

	playerbodygraphic = new PlayerIcon
	playerbodygraphic.setplayericon "human1 male"	

	playerclothesgraphic = new PlayerIcon
	playerclothesgraphic.setplayericon "chainmail shirt"
	#playerclothesgraphic.x = 8

	playerhatgraphic = new PlayerIcon
	playerhatgraphic.setplayericon "horned helmet"
	playerhatgraphic.x = 0
	playerhatgraphic.y = -8

	playershoesgraphic = new PlayerIcon
	playershoesgraphic.setplayericon "brown shoes"
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
		roguelikebase : roguelikebase,
		name: "You",
		health: 10,
		maxhealth : 10,
		sprite: compositeplayergraphic,
		dungeon: null,
		lightID:-1,
		basestats: CreatureList.DefaultPlayer,
		# x and y here are tile coordinates, not pixel coordinates
		x:0,
		y:0,
		inventory: [],
		inventorymaxsize: 16,

		# current wielded items
		weapon: null,
		armor: null,
		hat: null
	}

	playerdata.inventorywindow = new InventoryDisplay playerdata, 20,300
	playerdata.infowindow = new PlayerInfoDisplay playerdata,0,0

	playerdata.addedToDungeon = (dungeon, x, y) ->
		@dungeon = dungeon
		if dungeon.dungeonview?
			dungeon.dungeonview.addChild @sprite	

		@lightID = @dungeon.registerLight []
		@moveToTile x,y
		@setViewCenter x,y

	playerdata.removedFromDungeon = (dungeon) ->
		if dungeon.dungeonview?
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
				if @weapon? and @weapon.basestats.weapondamage > damageamount
					damageamount = @weapon.basestats.weapondamage
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
		if @weapon? and @weapon.basestats.providesarmor?
			amount = amount - @weapon.basestats.providesarmor
		if @armor? and @armor.basestats.providesarmor?
			amount = amount - @armor.basestats.providesarmor
		if @hat? and @hat.basestats.providesarmor?
			amount = amount - @hat.basestats.providesarmor
		if amount < 1
			amount = 1
		@health = @health - amount
		@infowindow.playerInfoChanged()
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
		if @weapon? and @weapon.basestats.onplayerspritename?
			playerweapon1graphic.setplayericon @weapon.basestats.onplayerspritename
			playerweapon1graphic.visible = true
		else
			playerweapon1graphic.visible = false
		# set default clothes as a brown robe if the player isn't wearing armor
		if @armor? and @armor.basestats.onplayerspritename?
			playerclothesgraphic.setplayericon @armor.basestats.onplayerspritename
		else
			playerclothesgraphic.setplayericon "brown robes"
		if @hat? and @hat.basestats.onplayerspritename?
			playerhatgraphic.setplayericon @hat.basestats.onplayerspritename
			playerhatgraphic.visible = true
		else
			playerhatgraphic.visible = false

	playerdata.eat = ->


	# initialize keyboard input
	playerdata.handleEvent = (evt) ->
    	#console.log evt
	    evt ||= window.event
	    playeraction = null
	    if evt.keyCode?
	    	# process as a keycode
	    	#
	    	# vi-style movement
	    	#
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
	    	else if evt.keyCode is ROT.VK_E
	    		playeraction = -> playerdata.eat()
	    	if playeraction isnt null and playeraction()
	    		@playerturnover()
	    if evt.ctrlKey and evt.keyCode is 90
        	alert "Ctrl-Z"

	playerdata.pickupItem = (item) ->
		@dungeon.removeItem item
		item.pickedUpBy this
		@inventory.push item
		roguelikebase.messagelog.addMessage "You pick up #{item.name}"
		@inventorywindow.inventorychanged()
		return true # player's turn is over

	playerdata.dropItem = (item) ->
		return true

	playerdata.playerDataChanged = ->
		@infowindow.playerInfoChanged()
		@updatePlayerSprite()
		roguelikebase.stage.update()

	playerdata.equipItem = (item) ->
		if item in @inventory
			invindex = @inventory.indexOf item
			@inventory.splice invindex,1

			# which item type?
			switch item.basestats.itemtype
				when "weapon" then @equipWeapon item
				when "armor" then @equipArmor item
				when "hat" then @equipHat item

	playerdata.unequipItem = (item) ->
		if item is @weapon then @unequipWeapon()
		if item is @armor then @unequipArmor()
		if item is @hat then @unequipHat()

	playerdata.equipWeapon = (weapon) ->
		# unequip whatever we already equipped
		if @weapon? then unequipWeapon @weapon
		roguelikebase.messagelog.addMessage "You wield #{weapon.name}"
		@weapon = weapon
		weapon.equippedBy this
		@playerDataChanged()

	playerdata.unequipWeapon = ->
		if @weapon?
			@weapon.unequippedBy this
			roguelikebase.messagelog.addMessage "You put away #{@weapon.name}"
			@weapon = null
			@playerDataChanged()

	playerdata.equipArmor = (armor) ->
		if @armor? then unequipArmor @armor
		roguelikebase.messagelog.addMessage "You wear #{armor.name}"
		@armor = armor
		armor.equippedBy this
		@playerDataChanged()

	playerdata.unequipArmor = ->
		if @armor?
			@armor.unequippedBy this
			roguelikebase.messagelog.addMessage "You take off #{@armor.name}"
			@armor = null
			@playerDataChanged()

	playerdata.equipHat = (hat) ->
		if @hat? then unequipHat @hat
		roguelikebase.messagelog.addMessage "You put on #{hat.name}"
		@hat = hat
		hat.equippedBy this
		@playerDataChanged()

	playerdata.unequipHat = ->
		if @hat?
			@hat.unequippedBy this
			roguelikebase.messagelog.addMessage "You take off #{@hat.name}"
			@hat = null
			@playerDataChanged()

	


	playerdata.updatePlayerSprite()
	return playerdata
