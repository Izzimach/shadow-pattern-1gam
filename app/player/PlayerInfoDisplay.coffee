module.exports = class PlayerInfoDisplay
	constructor: (@player, x, y) ->
		@roguelikebase = @player.roguelikebase
		@sprite = new createjs.Container()
		@sprite.x = x
		@sprite.y = y

		titletext = new createjs.Text "Player Data:", "Arial", "#fff"
		@sprite.addChild titletext

		itemsize = (require 'items/ItemSpriteSheet').itemtilesize
		slotpadding = 2
		slotsize = itemsize + slotpadding

		createSlot = (slotname, x, y) ->
			slot = new createjs.Container()
			slot.x = x
			slot.y = y
			text = new createjs.Text slotname, "Arial", "#ffffff"
			text.x = slotsize/2 + 4
			text.y = 0
			slot.addChild text


			slotsquare = new createjs.Shape()
			slotsquare.graphics.beginFill("#808080")
			slotsquare.graphics.drawRect(-slotsize/2, -slotsize/2, slotsize, slotsize)
			slot.addChild slotsquare

			slot.clearSprite = ->
				slot.removeChild slot.itemsprite if slot.itemsprite?
				slot.itemsprite = null

			slot.setItemSprite = (item) ->
				slot.clearSprite()
				if item?
					slot.itemsprite = item.sprite
					slot.addChild item.sprite
					item.sprite.x = 0
					item.sprite.y = 0

			return slot

		@weaponslot = createSlot "Weapon", slotsize, slotsize
		@armorslot = createSlot "Armor", slotsize, slotsize*2.5
		@hatslot = createSlot "Hat", slotsize,slotsize*4

		@sprite.addChild @weaponslot
		@sprite.addChild @armorslot
		@sprite.addChild @hatslot

		@healthtext = new createjs.Text "Health", "Arial", "#80ff80"
		@healthtext.y = slotsize * 5
		@healthtext.updateHealthtext = (player) ->
			if player.health < player.maxhealth/2
				@color = "#ff8080"
			else
				@color = "#80ff80"
			@text = "Health: #{player.health}/#{player.maxhealth}"

		@healthbar = new createjs.Shape()
		@healthbar.y = slotsize * 5.5
		@healthbar.updateHealthbar = (player) ->
			@graphics.clear()
			healthfraction = player.health / player.maxhealth
			totalhealthbarwidth = 100
			totalhealthbarheight = 30
			healthfractionpixels = totalhealthbarwidth * healthfraction
			missinghealthpixels = totalhealthbarwidth - healthfractionpixels
			@graphics.beginFill("#40ff40")
			@graphics.drawRect(0,0,healthfractionpixels,totalhealthbarheight)
			@graphics.beginFill("#804040")
			@graphics.drawRect(healthfractionpixels,0,missinghealthpixels,totalhealthbarheight)

		@sprite.addChild @healthtext
		@sprite.addChild @healthbar

		@playerInfoChanged()

		@roguelikebase.stage.addChild @sprite

	playerInfoChanged: ->
		@weaponslot.setItemSprite @player.weapon
		@armorslot.setItemSprite @player.armor
		@hatslot.setItemSprite @player.hat

		@healthtext.updateHealthtext @player
		@healthbar.updateHealthbar @player



