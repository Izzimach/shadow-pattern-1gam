# list of creatures for Shadow Pattern

# default stats
exports.Goblin =
	defaultname: "A grumpy goblin"
	speed: 100
	health: 3
	armor: 0
	basedamage: 2
	visualrange: 5
	level: 1
	spritename: "grumpy goblin" 

exports.Lizard =
	defaultname: "A lizard"
	speed: 200
	health: 2
	armor: 0
	basedamage: 1
	visualrange: 5
	level: 1
	spritename: "purple lizard"

exports.Phantom =
	defaultname: "A phantom"
	speed: 100
	health: 7
	armor: 0
	basedamage: 4
	visualrange: 5
	level: 2
	spritename: "phantom"

exports.Gargoyle =
	defaultname: "A red gargoyle"
	speed: 130
	health: 9
	armor: 2
	basedamage: 3
	visualrange: 5
	level: 3
	spritename: "flame gargoyle"

exports.Salamander =
	defaultname: "A fire elemental"
	speed: 130
	health: 11
	armor: 1
	basedamage: 8
	visualrange: 5
	level: 4
	spritename: "fire elemental"


exports.IceDemon =
	defaultname: "An ice demon"
	speed: 100
	health: 15
	armor: 5
	basedamage: 10
	visualrange: 5
	level: 5
	spritename: "ice demon" 

exports.WhiteDragon =
	defaultname: "A white dragon"
	speed: 100
	health: 20
	armor: 7
	basedamage: 10
	visualrange: 5
	level: 6
	spritename: "white dragon"

exports.Troll = 
	defaultname: "A troll"
	speed: 80
	health: 40
	armor: 6
	basedamage: 16
	visualrange: 5
	level: 8
	spritename: "green troll"


exports.Golem =
	defaultname: "A golem"
	speed: 50
	health: 35
	armor: 10
	basedamage: 16
	visualrange: 5
	level: 7
	spritename: "stone golem"

exports.Wizard =
	defaultname: "Evil Wizard Dude"
	speed: 100
	health : 35
	armor: 9
	basedamage: 16
	visualrange: 5
	level: 9
	spritename: "wizard dude"

# default player stats

exports.DefaultPlayer =
	defaultname : "You"
	speed: 100
	health: 10
	armor: 0
	basedamage: 1
	visualrange: 6
	level: 1
	# the player sprite is custom configured

exports.allCreatures = [
	exports.Goblin,
	exports.Lizard,
	exports.Phantom,
	exports.Gargoyle,
	exports.Salamander,	
	exports.IceDemon,
	exports.WhiteDragon,
	exports.Troll
]