module.exports = class InventoryDisplay
	constructor: (@player,x,y) ->
		@roguelikebase = @player.roguelikebase
		
		@sprite = new createjs.Container()
		@sprite.x = x
		@sprite.y = y

		@tilesacross = 4
		@tilesdown = 4
		@itemsize = (require 'items/ItemSpriteSheet').itemtilesize
		@itemhalfsize = @itemsize / 2
		@inventorydisplaypadding = 4
		@itemspacing = @itemsize + @inventorydisplaypadding

		background = new createjs.Shape()
		background.graphics.beginFill("#202020")
		background.graphics.drawRect(-@itemspacing/2, -@itemspacing*1.4, (@tilesacross) * @itemspacing + 2, (@tilesdown+1) * @itemspacing)
		background.graphics.beginFill("#808080")
		for itemindex in [0...@player.inventorymaxsize]
			itemx = @itemspacing * (itemindex % @tilesacross)
			itemy = @itemspacing * Math.floor(itemindex / @tilesacross)
			background.graphics.drawRect(itemx - @itemhalfsize, itemy - @itemhalfsize, @itemsize, @itemsize)
		@sprite.addChild background

		title = new createjs.Text "Inventory", "Arial", "#f0ff80"
		title.y = -@itemspacing
		@sprite.addChild title

		@items = new createjs.Container()
		@sprite.addChild @items

		@roguelikebase.stage.addChild @sprite

	inventorychanged: ->
		@items.removeAllChildren()
		for itemindex in [0...@player.inventory.length]
			item = @player.inventory[itemindex]
			itemx = @itemspacing * (itemindex % @tilesacross)
			itemy = @itemspacing * Math.floor(itemindex / @tilesacross)
			@items.addChild item.sprite
			item.sprite.x = itemx
			item.sprite.y = itemy
