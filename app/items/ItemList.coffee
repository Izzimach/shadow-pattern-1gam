exports.BasicSword = {
	spritename : "sword",
	onplayerspritename : "sword",
	defaultname: "a sword",
	description: "Just your everyday sword",
	itemtype : "weapon",
	weapondamage: 5,
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
	description: "A tasty banana heals half of your health",
	itemtype : "food",
	healingamount : 0.5
}

exports.allItems = [
	exports.BasicSword,
	exports.Chainmail,
	exports.JauntyHat,
	exports.Banana
]
