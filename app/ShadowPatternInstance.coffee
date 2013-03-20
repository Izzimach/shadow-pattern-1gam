dungeonmodule = require 'dungeon'
playermodule = require 'player/player'
Monster = require 'creatures/Monster'
Item = require 'items/Item'



module.exports = class ShadowPatternInstance
	constructor: (@roguelikebase) ->
		roguelikebase.gameinstance = this
		roguelikebase.stage.removeAllChildren()

		dungeonview = new createjs.Container()
		dungeonview.name = "dungeonview"
		roguelikebase.stage.addChild dungeonview

		roguelikebase.engine = new ROT.Engine()

		dungeon = dungeonmodule.createDungeon roguelikebase
		dungeonmodule.installDungeon roguelikebase, dungeon

		player = playermodule.createPlayer roguelikebase
		roguelikebase.player = player
		playerstarttile = dungeon.upstairstile
		dungeon.addPlayer player, playerstarttile.tilex, playerstarttile.tiley

		creatures = (require 'creatures/CreatureList').allCreatures
		for multi in [1..3]
			creaturestats = creatures[Math.floor(Math.random() * creatures.length)]
			somemonster = new Monster creaturestats, roguelikebase
			monsterstarttile = dungeon.pickFloorTile()
			dungeon.addMonster somemonster, monsterstarttile.tilex, monsterstarttile.tiley

		items = (require 'items/ItemList').allItems
		for multi in [0...10]
			itemstats = items[Math.floor(Math.random() * items.length)]
			someitem = new Item itemstats, roguelikebase
			itemstarttile = dungeon.pickFloorTile()
			dungeon.addItem someitem, itemstarttile.tilex, itemstarttile.tiley

		roguelikebase.messagelog = new createjs.Text "Welcome to Shadow Pattern!", "15px Arial", "#ddd"
		roguelikebase.messagelog.lineHeight = 14 #roguelikebase.messagelog.getMeasuredHeight()
		roguelikebase.messagelog.messages = []
		roguelikebase.messagelog.x = 200
		roguelikebase.messagelog.addMessage = (message) ->
			if @messages.length > 10
				@messages.splice 0,@messages.length-10
			@messages.push message
			@text = @messages.join "\n"
		roguelikebase.stage.addChild roguelikebase.messagelog

		return roguelikebase.gameinstance

	gameOver: ->
		gameoverwindow = new createjs.Container
		gameoverwindow.x = @roguelikebase.stage.canvas.width/2
		gameoverwindow.y = @roguelikebase.stage.canvas.height/2

		gameovertext = new createjs.Text "Game Over!", "bold 40px Arial", "#fff"
		gameovertext.textAlign = "center"
		gameovertext.shadow = new createjs.Shadow "#000",5,5,10
		gameovertext.x = 0 # @roguelikebase.stage.canvas.width/2
		gameovertext.y = -100 # @roguelikebase.stage.canvas.height/2
		gameoverwindow.addChild gameovertext

		buttonwidth = 200
		buttonheight = 100
		playagainbutton = new createjs.Shape()
		playagainbutton.graphics.beginFill "#303030"
		playagainbutton.graphics.drawRect -buttonwidth/2,-buttonheight/2, buttonwidth, buttonheight
		playagainbutton.addEventListener "click", => @roguelikebase.startGame()

		gameoverwindow.addChild playagainbutton

		playagaintext = new createjs.Text "Click here to restart", "Arial", "#a0a0a0"
		playagaintext.textAlign = "center"
		gameoverwindow.addChild playagaintext

		@roguelikebase.stage.addChild gameoverwindow

		@roguelikebase.stage.update()




