extends Node


# Enums
enum difficulties {
	EASY,
	NORMAL,
	HARD
}

var difficulty := difficulties.NORMAL # How difficult is this level?

# Node Counters
var wallCount := 0 # Total number of wall panels in this level
var floorCount := 0 # Total number rof floor panels in this level
var enemyCount := 0 # How many enemies are in this level?
var enemiesAlive := 0 # How many enemies are alive?
var healthPickups := 0 # How many health pickups are in this level?
var ammoPickups := 0 # How many ammo pickups are in this level?

var levelRoot := preload("res://Scenes/LevelRoot.tscn")
var nextLevel: Node = null
var currentLevel: Node = null
var levelTime := 0.0 # How long has this level been running?
var score := 0 # How many points has the player earned?
var inProgress := false # Is a level in progress?

# Called to retrieve a new level from the LevelGenerator
func makeLevel() -> bool:
	resetConstruction()
	nextLevel = levelRoot.instantiate()
	LevelGenerator.generate_level(difficulty)
	return true


func startGame() -> void:
	if nextLevel:
		if currentLevel:
			currentLevel.queue_free()
		currentLevel = nextLevel
		nextLevel = null
		get_tree().root.add_child(currentLevel)
		resetGame()
		inProgress = true


func changeScore(value) -> void:
	score += value
	print("New score: ", score)


func resetConstruction() -> void:
	wallCount = 0
	floorCount = 0
	enemyCount = 0
	enemiesAlive = 0
	healthPickups = 0
	ammoPickups = 0


func resetGame() -> void:
	levelTime = 0
	score = 0
	inProgress = false
