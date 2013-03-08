shadow-pattern-1gam
===================

Shadow Pattern is a Roguelike game written using Javascript for the One Game A Month challenge.

## To Build and Play
Shadow Pattern uses the [brunch](http://brunch.io) build tool, which depends on [node.js](http://nodejs.org)

After installing node.js (which also includes npm) you can install brunch using

	npm install -g brunch

then in the root directory run

	brunch build

the results are placed into the /public directory. You may need to run a http server to run the game properly, in which case you can
use [node-static](https://github.com/cloudhead/node-static) or simply run the server built into brunch:

	brunch watch --server

## Adding abilities, items, and monsters

