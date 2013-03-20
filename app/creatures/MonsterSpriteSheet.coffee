# sprite map for monsters

MonsterSpriteData = {
	"grumpy goblin" : [19*32, 12*32, 32,32, 0, 16,16],
	"flame gargoyle" : [0, 32, 32,32, 0,16,16],
	"ice demon" : [160,32, 32,32, 0,16,16],
	"electric eel" : [0,32*32, 32,32, 0,16,16],
	"phantom" : [4*32,2*32, 32,32, 0,16,16],
	"purple lizard": [18*32, 11*32, 32,32, 0,16,16],
	"stone golem" : [18*32,10*32, 32,32, 0,16,16],
	"green troll" : [12*32, 9*32, 32,32, 0,16,16]
}

MonsterSpriteNames = (key for key of MonsterSpriteData)
MonsterSpriteFrames = (MonsterSpriteData[iconname] for iconname in MonsterSpriteNames)

spritesheet = null

createSprite = (spritename, roguelikebase) ->
	if spritesheet is null
		spritesheet = new createjs.SpriteSheet {images:[roguelikebase.assets.images["monsters-alpha"]], frames: MonsterSpriteFrames}
	sprite = new createjs.BitmapAnimation spritesheet
	sprite.gotoAndStop MonsterSpriteNames.indexOf spritename
	return sprite

exports.Names = MonsterSpriteNames
exports.createSprite = createSprite
