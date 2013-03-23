exports.Dagger = {
	spritename : "dagger",
	onplayerspritename : "dagger",
	defaultname: "a dagger",
	description: "Stabbity stab",
	itemtype : "weapon",
	weapondamage: 2,
	enchantable : true,
	level:1
}

exports.SpikedClub = {
	spritename : "spiked club",
	onplayerspritename : "spiked club",
	defaultname: "a club",
	description: "A big spiky club",
	itemtype : "weapon",
	weapondamage: 4,
	enchantable : true,
	level: 2
}

exports.BasicAxe = {
	spritename : "big axe",
	onplayerspritename : "axe",
	defaultname: "an axe",
	description: "Just your everyday axe",
	itemtype : "weapon",
	weapondamage: 6,
	enchantable : true,
	level: 3
}

exports.BasicSword = {
	spritename : "sword",
	onplayerspritename : "sword",
	defaultname: "a sword",
	description: "Just your everyday sword",
	itemtype : "weapon",
	weapondamage: 8,
	enchantable : true,
	level:4
}

exports.Scimitar = {
	spritename : "scimitar",
	onplayerspritename : "scimitar",
	defaultname: "a scimitar",
	description: "as far as you're concerned it's a sword",
	itemtype : "weapon",
	weapondamage: 8,
	enchantable : true,
	level:4
}

exports.Halberd = {
	spritename : "halberd",
	onplayerspritename : "halberd",
	defaultname: "a polearm",
	description: "A blade on a big stick",
	itemtype : "weapon",
	weapondamage: 9,
	providesarmor: 1,
	enchantable : true,
	level: 5
}

exports.BlackSword = {
	spritename : "dark sword",
	onplayerspritename : "",
	defaultname: "an obsidian sword",
	description: "A magically crafted sword made of obsidian",
	itemtype : "weapon",
	weapondamage: 14,
	enchantable : true,
	level: 6
}


exports.Leather = {
	spritename : "leather armor",
	onplayerspritename : "leather armor",
	defaultname: "Leather Armor",
	description: "Hardened leather armor",
	itemtype : "armor",
	providesarmor : 1,
	enchantable : true,
	level: 1
}

exports.Chainmail = {
	spritename : "chainmail",
	onplayerspritename : "chainmail shirt",
	defaultname: "Chainmail",
	description: "A simple coat made of metal rings",
	itemtype : "armor",
	providesarmor : 2,
	enchantable : true,
	level: 3
}

exports.Bandedmail = {
	spritename : "banded mail",
	onplayerspritename : "banded mail",
	defaultname: "Banded mail",
	description: "Armor made from strips of metal",
	itemtype : "armor",
	providesarmor : 3,
	enchantable : true,
	level: 4
}

exports.CrystalArmor = {
	spritename : "crystal armor",
	onplayerspritename : "crystal armor",
	defaultname: "Crystal Armor",
	description: "Mysterious armor made from crystals",
	itemtype : "armor",
	providesarmor : 5,
	enchantable : true,
	level: 6
}

exports.JauntyHat = {
	spritename: "jaunty hat",
	onplayerspritename: "fancy hat",
	defaultname: "a jaunty hat",
	description: "The feather really complements your ensemble",
	itemtype : "hat",
	providesarmor: 0,
	speedboost: 10,
	enchantable : true,
	level: 1
}


exports.MetalHelm = {
	spritename: "helmet",
	onplayerspritename: "steel helmet",
	defaultname: "a metal helm",
	description: "",
	itemtype : "hat",
	providesarmor: 2,
	enchantable : true,
	level: 3
}

exports.WizardHat = {
	spritename: "pointy hat",
	onplayerspritename: "wizard hat",
	defaultname: "a wizard hat",
	description: "Wizards love pointy hats",
	itemtype : "hat",
	providesarmor: 2,
	speedboost: 30,
	enchantable : true,
	level: 5
}

exports.DragonHelm = {
	spritename: "winged helmet",
	onplayerspritename: "dragon helm",
	defaultname: "a winged helmet",
	description: "Made long ago using methods long forgotten",
	itemtype : "hat",
	providesarmor: 5,
	speedboost: 0,
	enchantable : true,
	level: 7
}

exports.Banana = {
	spritename: "banana",
	defaultname: "a banana",
	description: "A tasty banana heals most of your health",
	itemtype : "food",
	healingfraction : 0.8,
	level: 4
}

exports.Strawberry = {
	spritename: "strawberry",
	defaultname: "a strawberry",
	description: "A tasty strawberry heals half of your health",
	itemtype : "food",
	healingfraction : 0.5,
	level: 1
}

exports.Grapes = {
	spritename: "grapes",
	defaultname: "some grapes",
	description: "Grapes are good for you",
	itemtype : "food",
	healingfraction : 0.6,
	level: 2
}

exports.Cheese = {
	spritename: "cheese",
	defaultname: "some cheese",
	description: "Thank goodness it's not the stinky kind",
	itemtype : "food",
	healingfraction : 0.7,
	level: 3
}

exports.allItems = [
	exports.Dagger,
	exports.BasicSword,
	exports.Scimitar,
	exports.BasicAxe,
	exports.SpikedClub,
	exports.Halberd,
	exports.BlackSword,

	exports.CrystalArmor,
	exports.Bandedmail,
	exports.Chainmail,
	exports.Leather,

	exports.JauntyHat,
	exports.WizardHat,
	exports.MetalHelm,
	exports.DragonHelm,

	exports.Banana,
	exports.Strawberry,
	exports.Grapes,
	exports.Cheese
]
