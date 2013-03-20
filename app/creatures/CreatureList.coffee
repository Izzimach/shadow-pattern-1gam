# list of creatures for Shadow Pattern

# default stats
exports.Goblin = {
	defaultname: "A grumpy goblin",
	speed: 100,
	health: 3,
	armor: 0,
	basedamage: 2,
	visualrange: 5,
	level: 1,
	spritename: "grumpy goblin" 
}

exports.Demon = {
	defaultname: "An ice demon",
	speed: 120,
	health: 50,
	armor: 5,
	basedamage: 14,
	visualrange: 5,
	level: 7,
	spritename: "ice demon" 
}


exports.Troll = {
	defaultname: "A troll",
	speed: 70,
	health: 50,
	armor: 2,
	basedamage: 6,
	visualrange: 5,
	level: 5,
	spritename: "green troll" 
}

exports.Gargoyle = {
	defaultname: "A red gargoyle",
	speed: 130,
	health: 5,
	armor: 0,
	basedamage: 3,
	visualrange: 5,
	level: 2,
	spritename: "flame gargoyle" 
}

# default player stats

exports.DefaultPlayer = {
	defaultname : "You",
	speed: 100,
	health: 20,
	armor: 0,
	basedamage: 1,
	visualrange: 6,
	level: 1
	# the player sprite is custom configured
}

exports.allCreatures = [
	exports.Goblin,
	exports.Troll,
	exports.Gargoyle,
	exports.Demon

]