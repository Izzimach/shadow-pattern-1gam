# sprite map for monsters

ItemSpriteData = {
	"sword" : [0*32, 2*32, 32,32, 0, 16,16],
	"club" : [7*32, 1*32, 32,32,0,16,16],
	"axe" : [12*32, 2*32, 32,32,0,16,16],

	"hat" : [0,8*32, 32,32, 0,16,16],
	"jaunty hat" : [0, 8*32, 32,32, 0,16,16],

	"chainmail" : [2*32, 6*32, 32,32, 0,16,16]
}
ItemSpriteNames = (key for key of ItemSpriteData)
ItemSpriteFrames = (ItemSpriteData[iconname] for iconname in ItemSpriteNames)

spritesheet = null

createSprite = (spritename, roguelikebase) ->
	if spritesheet is null
		spritesheet = new createjs.SpriteSheet {images:[roguelikebase.assets.images["items-alpha"]], frames: ItemSpriteFrames}
	sprite = new createjs.BitmapAnimation spritesheet
	sprite.gotoAndStop ItemSpriteNames.indexOf spritename
	return sprite

exports.Names = ItemSpriteNames
exports.createSprite = createSprite