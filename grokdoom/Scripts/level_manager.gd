extends Node

enum Difficulties { EASY, NORMAL, HARD }
# Generated Level NodeHolders
var generator := LevelGenerator.new()
var nextLevel: Node
var currentLevel: Node

# Node Counters
var wallCount := 0 # Total number of wall panels in this level
var floorCount := 0 # Total number rof floor panels in this level
var enemyCount := 0 # How many enemies are in this level?
var healthPickups := 0 # How many health pickups are in this level?
var ammoPickups := 0 # How many ammo pickups are in this level?

# Current Game Data
var levelTime := 0.0 # How long has this level been running?
var enemiesAlive := 0 # How many enemies are alive?
var score := 0 # How many points has the player earned?
var inProgress := false # Is a level in progress?


# Called to genrate a new level using LevelGenerator
func makeLevel() -> bool:
	resetConstruction() # Reset Node Counters
	nextLevel = generator.generate_level() # Create a new instance of the LevelRoot for building a new level
	return true # If this is done, return true


# Called to remove currentLevel from the GameRoot and add nextLevel to the GameRoot
func startGame() -> void:
	if nextLevel: # If a nextLevel has been created, removed current and add next
		if currentLevel:
			currentLevel.queue_free() # If a current level exists, remove it from the tree and RAM
		
		currentLevel = nextLevel # Change pointer references
		nextLevel = null
		
		get_tree().current_scene.add_child(currentLevel) # Add nextLevel to the GameRoot
		
		resetGame() # Reset the Current Game Data
		inProgress = true # Let the application know a game is in progress


# Called when score needs to be updated
func changeScore(value) -> void:
	score += value # Add a new value to the current score (can be a negative number)
	if score <= 0:
		score = 0 # Don't let the player have less than 0 points
	print("New score: ", score)


# Called to reset the Node Counters before building a new level
func resetConstruction() -> void:
	wallCount = 0
	floorCount = 0
	enemyCount = 0
	enemiesAlive = 0
	healthPickups = 0
	ammoPickups = 0


# Called to reset Current Game Data
func resetGame() -> void:
	levelTime = 0
	score = 0
	inProgress = false
