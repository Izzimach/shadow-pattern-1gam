# sprite map for monsters

MonsterSpriteData = {
	"grumpy goblin" : [19*32, 12*32, 32,32, 0, 16,16]
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
