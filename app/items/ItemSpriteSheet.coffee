# sprite map for monsters

ItemSpriteData = {
	"spiked club" : [8*32, 1*32, 32,32,0,16,16],
	"sword" : [0*32, 2*32, 32,32, 0, 16,16],
	"big axe" : [13*32, 2*32, 32,32,0,16,16],
	"dagger" : [13*32, 1*32, 32,32, 0,16,16],
	"scimitar" : [3*32,2*32, 32,32, 0,16,16],
	"dark sword" : [11*32,2*32, 32,32, 0,16,16],
	"halberd" : [7*32, 3*32, 32,32, 0,16,16],


	"hat" : [0,8*32, 32,32, 0,16,16],
	"jaunty hat" : [0, 8*32, 32,32, 0,16,16],
	"pointy hat" : [32,8*32, 32,32, 0,16,16],
	"helmet" : [3*32,8*32, 32,32, 0,16,16],
	"winged helmet" : [4*32,8*32, 32,32, 0,16,16],

	"chainmail" : [4*32, 6*32, 32,32, 0,16,16],
	"banded mail" : [6*32, 6*32, 32,32, 0,16,16],
	"steel platemail" : [8*32,6*32, 32,32, 0,16,16],
	"crystal armor" : [10*32,6*32, 32,32, 0,16,16],
	"leather armor" : [14*32, 5*32, 32,32, 0,16,16],

	"banana" : [17*32,9*32, 32,32, 0,16,16],
	"strawberry" : [18*32,9*32, 32,32, 0,16,16],
	"grapes" : [1*32, 10*32, 32,32, 0,16,16],
	"cheese" : [5*32, 10*32, 32,32, 0,16,16]
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
exports.itemtilesize = 32
