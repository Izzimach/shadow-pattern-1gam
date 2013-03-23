InventoryDisplay = require 'player/InventoryDisplay'
PlayerInfoDisplay = require 'player/PlayerInfoDisplay'
CreatureList = require 'creatures/CreatureList'

exports.createPlayer = (@roguelikebase) ->
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

	spriteSheet = new createjs.SpriteSheet {images:[@roguelikebase.assets.images["player-alpha"]], frames: playerframes}

	playershadowgraphic = new PlayerIcon
	playershadowgraphic.setplayericon "player shadow"

	playercloakgraphic = new PlayerIcon
	playercloakgraphic.setplayericon "red cloak"
	playercloakgraphic.visible = false

	playerbodygraphic = new PlayerIcon
	playerbodygraphic.setplayericon "human1 male"	

	playerpantsgraphic = new PlayerIcon
	playerpantsgraphic.setplayericon "brown pants"
	playerpantsgraphic.y = 8

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
	compositeplayergraphic.addChild playerpantsgraphic
	compositeplayergraphic.addChild playerclothesgraphic
	compositeplayergraphic.addChild playerhatgraphic
	compositeplayergraphic.addChild playerweapon1graphic
	compositeplayergraphic.addChild playerweapon2graphic

	playerbase = CreatureList.DefaultPlayer

	playerdata = {
		roguelikebase : roguelikebase,
		name: "You",
		health: playerbase.health,
		maxhealth : playerbase.health,
		sprite: compositeplayergraphic,
		dungeon: null,
		lightID:-1,
		basestats: CreatureList.DefaultPlayer,
		# x and y here are tile coordinates, not pixel coordinates
		x:0,
		y:0,
		inventory: [],
		inventorymaxsize: 20,

		# current wielded items
		weapon: null,
		armor: null,
		hat: null
	}

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
		stagecenterx = @roguelikebase.stage.canvas.width/2
		stagecentery = @roguelikebase.stage.canvas.height/2
		dungeonview = @roguelikebase.stage.getChildByName "dungeonview"
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
				@pickupItemNoTurnOver pickupme
			@playerTurnOver()
		else
			monster = @dungeon.monsterAt newx,newy
			#console.log monster
			if monster
				damageamount = @getDamage()
				damageamount = monster.applyDamage damageamount
				@roguelikebase.messagelog.addMessage "#{@name} attack #{monster.name} for #{damageamount} damage"
				if monster.health < 0
					@roguelikebase.messagelog.addMessage "You have killed #{monster.name}!"
					# no XP; instead bump player's health
					@maxhealth = @maxhealth + 3
					@health = @health + 3

				@playerTurnOver()
			else
				@roguelikebase.messagelog.addMessage "You run into a wall"
				@roguelikebase.stage.update()
				return false # doesn't count as an action

	playerdata.applyDamage = (amount) ->
		# reduce damage by armor provided via items
		amount = amount - @getArmorAmount()
		if amount < 1
			amount = 1
		@health = @health - amount
		@infowindow.playerInfoChanged()
		return amount

	# for ROT.engine and ROT.scheduler
	playerdata.getSpeed = ->
		speed = @basestats.speed
		if @weapon? and @weapon.basestats.speedboost?
			speed = speed + @weapon.basestats.speedboost
		if @armor? and @armor.basestats.speedboost?
			speed = speed + @armor.basestats.speedboost
		if @hat? and @hat.basestats.speedboost?
			speed = speed + @hat.basestats.speedboost
		return speed

	playerdata.getDamage = ->
		if @weapon?
			return @weapon.basestats.weapondamage
		else
			return @basestats.basedamage # punching damage w/out weapon

	playerdata.getArmorAmount = ->
		armoramount = 0
		if @weapon? and @weapon.basestats.providesarmor?
			armoramount = armoramount + @weapon.basestats.providesarmor
		if @armor? and @armor.basestats.providesarmor?
			armoramount = armoramount + @armor.basestats.providesarmor
		if @hat? and @hat.basestats.providesarmor?
			armoramount = armoramount + @hat.basestats.providesarmor
		return armoramount

	playerdata.act = ->
		# halt the engine, and wait for keyboard input
		@roguelikebase.engine.lock()
		@dungeon.updateVisibleObjects()
		@roguelikebase.stage.update()
		if @health < 0
			@roguelikebase.gameinstance.gameOver()
		else
			window.addEventListener "keydown", this

	playerdata.playerTurnOver = ->
		window.removeEventListener "keydown", this
		@playerDataChanged()  # presumably the player did SOMETHING this turn
		@roguelikebase.stage.update()
		@roguelikebase.engine.unlock()

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
		edibleitems = (item for item in @inventory when item.basestats.itemtype is "food")
		if edibleitems.length > 0
			toeat = edibleitems[0]
			toeatindex = @inventory.indexOf toeat
			@inventory.splice toeatindex,1
			@eatFood toeat
		else
			@roguelikebase.messagelog.addMessage "You have nothing to eat!"

	playerdata.eatFood = (food) ->
			@health = Math.floor(@health + @maxhealth * food.basestats.healingfraction)
			@health = @maxhealth if @health > @maxhealth
			@roguelikebase.messagelog.addMessage "You eat #{food.name}"
			@playerDataChanged()
			@playerTurnOver()

	playerdata.wield = ->

	# initialize keyboard input
	playerdata.handleEvent = (evt) ->
    	#console.log evt
	    evt ||= window.event
	    playeraction = null
	    if evt.ctrlKey and evt.keyCode is 90
        	alert "Ctrl-Z"
	    else if evt.keyCode?
	    	# process as a keycode
	    	#
	    	# vi-style movement
	    	#
	    	if evt.keyCode is ROT.VK_H then playerdata.step -1,0
	    	else if evt.keyCode is ROT.VK_L then playerdata.step 1,0
	    	else if evt.keyCode is ROT.VK_K then playerdata.step 0,-1
	    	else if evt.keyCode is ROT.VK_J then playerdata.step 0,1
	    	# diagonals
	    	else if evt.keyCode is ROT.VK_Y then playerdata.step -1,-1
	    	else if evt.keyCode is ROT.VK_U then playerdata.step 1,-1
	    	else if evt.keyCode is ROT.VK_B then playerdata.step -1,1
	    	else if evt.keyCode is ROT.VK_N then playerdata.step 1,1
	    	else if evt.keyCode is ROT.VK_PERIOD then @playerTurnOver()
	    	# numpad movement
	    	else if evt.keyCode is ROT.VK_NUMPAD1 then playerdata.step -1,1
	    	else if evt.keyCode is ROT.VK_NUMPAD2 then playerdata.step 0,1
	    	else if evt.keyCode is ROT.VK_NUMPAD3 then playerdata.step 1,1
	    	else if evt.keyCode is ROT.VK_NUMPAD4 then playerdata.step -1,0
	    	else if evt.keyCode is ROT.VK_NUMPAD5 then @playerTurnOver()
	    	else if evt.keyCode is ROT.VK_NUMPAD6 then playerdata.step 1,0
	    	else if evt.keyCode is ROT.VK_NUMPAD7 then playerdata.step -1,-1
	    	else if evt.keyCode is ROT.VK_NUMPAD8 then playerdata.step 0,-1
	    	else if evt.keyCode is ROT.VK_NUMPAD9 then playerdata.step 1,-1
	    	# arrows and home/end/pgup/pgdn movement
	    	else if evt.keyCode is ROT.VK_LEFT then playerdata.step -1,0
	    	else if evt.keyCode is ROT.VK_RIGHT then playerdata.step 1,0
	    	else if evt.keyCode is ROT.VK_UP then playerdata.step 0,-1
	    	else if evt.keyCode is ROT.VK_DOWN then playerdata.step 0,1
	    	else if evt.keyCode is ROT.VK_HOME then playerdata.step -1,-1
	    	else if evt.keyCode is ROT.VK_END then playerdata.step -1,1
	    	else if evt.keyCode is ROT.VK_PAGE_UP then playerdata.step 1,-1
	    	else if evt.keyCode is ROT.VK_PAGE_DOWN then playerdata.step 1,1
	    	# eat and wield
	    	else if evt.keyCode is ROT.VK_E then playerdata.eat()
	    	else if evt.keyCode is ROT.VK_W then playerdata.wield()

    playerdata.possiblyDisplayItemHelpText = (item) ->
    	playerdata.showedhelpflags = [] unless playerdata.showedhelpflags?
    	switch item.basestats.itemtype
    		when "weapon"
    			unless "weaponhelp" in playerdata.showedhelpflags
    				@roguelikebase.messagelog.addMessage "Click on a weapon in your inventory to equip it"
    				playerdata.showedhelpflags.push "weaponhelp"
    		when "armor"
    			unless "armorhelp" in playerdata.showedhelpflags
    				@roguelikebase.messagelog.addMessage "Click on armor in your inventory to wear it"
    				playerdata.showedhelpflags.push "armorhelp"
    		when "hat"
    			unless "hathelp" in playerdata.showedhelpflags
    				@roguelikebase.messagelog.addMessage "Click on a hat in your inventory to wear it"
    				playerdata.showedhelpflags.push "hathelp"
    		when "food"
    			unless "foodhelp" in playerdata.showedhelpflags
    				@roguelikebase.messagelog.addMessage "Click on food in your inventory to eat it, or press 'e' to eat food"
    				playerdata.showedhelpflags.push "foodhelp"

	playerdata.pickupItemNoTurnOver = (item) ->
		@dungeon.removeItem item
		item.pickedUpBy this
		@inventory.push item
		@roguelikebase.messagelog.addMessage "You pick up #{item.name}"
		@possiblyDisplayItemHelpText item
		@playerDataChanged()

	playerdata.pickupItem = (item) ->
		@pickupItemNoTurnOver item
		@playerTurnOver()

	playerdata.dropItem = (item) ->
		itemindex = @inventory.indexOf item
		if itemindex >=0
			@inventory.splice itemindex,1
			@dungeon.addItem item,@x,@y
			@roguelikebase.messagelog.addMessage "You drop #{item.name}"
		@playerTurnOver()

	playerdata.playerDataChanged = ->
		@inventorywindow.inventorychanged()
		@infowindow.playerInfoChanged()
		@updatePlayerSprite()

	playerdata.equipItem = (item) ->
		if item in @inventory
			invindex = @inventory.indexOf item
			@inventory.splice invindex,1

			# which item type?
			switch item.basestats.itemtype
				when "weapon" then @equipWeapon item
				when "armor" then @equipArmor item
				when "hat" then @equipHat item
				when "food" then @eatFood item

	playerdata.unequipItem = (item) ->
		if item is @weapon then @unequipWeapon()
		if item is @armor then @unequipArmor()
		if item is @hat then @unequipHat()

	playerdata.equipWeapon = (weapon) ->
		# unequip whatever we already equipped
		if @weapon? then @unequipWeapon false
		@roguelikebase.messagelog.addMessage "You wield #{weapon.name}"
		@weapon = weapon
		weapon.equippedBy this
		@playerTurnOver()

	playerdata.unequipWeapon = (endturn) ->
		if @weapon?
			@weapon.unequippedBy this
			@roguelikebase.messagelog.addMessage "You put away #{@weapon.name}"
			@inventory.push @weapon
			@weapon = null
			@playerTurnOver() if endturn

	playerdata.equipArmor = (armor) ->
		if @armor? then @unequipArmor false
		@roguelikebase.messagelog.addMessage "You wear #{armor.name}"
		@armor = armor
		armor.equippedBy this
		@playerTurnOver()

	playerdata.unequipArmor = (endturn) ->
		if @armor?
			@armor.unequippedBy this
			@roguelikebase.messagelog.addMessage "You take off #{@armor.name}"
			@inventory.push @armor
			@armor = null
			@playerTurnOver() if endturn

	playerdata.equipHat = (hat) ->
		if @hat? then @unequipHat false
		@roguelikebase.messagelog.addMessage "You put on #{hat.name}"
		@hat = hat
		hat.equippedBy this
		@playerTurnOver()

	playerdata.unequipHat = (endturn) ->
		if @hat?
			@hat.unequippedBy this
			@roguelikebase.messagelog.addMessage "You take off #{@hat.name}"
			@inventory.push @hat
			@hat = null
			@playerTurnOver() if endturn
	
	playerdata.inventorywindow = new InventoryDisplay playerdata, 20,350
	playerdata.infowindow = new PlayerInfoDisplay playerdata,0,0

	playerdata.updatePlayerSprite()
	return playerdata
