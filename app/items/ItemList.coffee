exports.BasicSword = {
	spritename : "sword",
	onplayerspritename : "sword",
	defaultname: "a sword",
	description: "Just your everyday sword",
	itemtype : "weapon",
	weapondamage: 3,
	enchantable : true
}

exports.SpikedClub = {
	spritename : "spiked club",
	onplayerspritename : "spiked club",
	defaultname: "a club",
	description: "A big spiky club",
	itemtype : "weapon",
	weapondamage: 2,
	enchantable : true
}

exports.BasicAxe = {
	spritename : "big axe",
	onplayerspritename : "axe",
	defaultname: "an axe",
	description: "Just your everyday axe",
	itemtype : "weapon",
	weapondamage: 4,
	enchantable : true
}

exports.Chainmail = {
	spritename : "chainmail",
	onplayerspritename : "chainmail shirt",
	defaultname: "Chainmail",
	description: "A simple coat made of metal rings",
	itemtype : "armor",
	providesarmor : 2,
	enchantable : true
}

exports.Leather = {
	spritename : "leather armor",
	onplayerspritename : "leather armor",
	defaultname: "Leather Armor",
	description: "Hardened leather armor",
	itemtype : "armor",
	providesarmor : 1,
	enchantable : true
}

exports.JauntyHat = {
	spritename: "jaunty hat",
	onplayerspritename: "fancy hat",
	defaultname: "a jaunty hat",
	description: "The feather really complements your ensemble",
	itemtype : "hat",
	providesarmor: 1,
	enchantable : true
}

exports.Banana = {
	spritename: "banana",
	defaultname: "a banana",
	description: "A tasty banana heals most of your health",
	itemtype : "food",
	healingfraction : 0.8
}

exports.Strawberry = {
	spritename: "strawberry",
	defaultname: "a strawberry",
	description: "A tasty strawberry heals half of your health",
	itemtype : "food",
	healingfraction : 0.5
}

exports.allItems = [
	exports.BasicSword,
	exports.BasicAxe,
	exports.SpikedClub,
	exports.Chainmail,
	exports.Leather,
	exports.JauntyHat,
	exports.Banana,
	exports.Strawberry
]
