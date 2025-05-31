class_name LevelGenerator extends Node

# Level Construction Parameters
var tile_size := 2.0
var map_width := 10
var map_height := 10
var enemy_count := 5
var pickup_count := 3
var ammo_count := 2
var valid_spawn_positions: Array[Vector3] = []  # Store valid spawn positions


# Called to generate a level
func generate_level() -> Node:
	var floorScene := preload(Scenes.BASIC_FLOOR)
	var wallScene := preload(Scenes.BASIC_WALL)
	var ammoScene := preload(Scenes.BASIC_AMMO)
	var hpScene := preload(Scenes.BASIC_HEALTHKIT)
	var enemyScenes := {
		Enemy.EnemyTypes.CAPSULE: preload(Scenes.ENEMIES[Enemy.EnemyTypes.CAPSULE]),
		Enemy.EnemyTypes.ZOMBIE: preload(Scenes.ENEMIES[Enemy.EnemyTypes.ZOMBIE]),
		Enemy.EnemyTypes.ZOMBIER: preload(Scenes.ENEMIES[Enemy.EnemyTypes.ZOMBIER]),
	}
	
	# Create new base Nodes
	var player := preload("res://Scenes/Player.tscn").instantiate()
	var hud := preload("res://Scenes/HUD.tscn").instantiate()
	var level := Node.new()
	var floors := Node.new()
	var walls := Node.new()
	var enemies := Node.new()
	var pickups := Node.new()
	# Name the generic Nodes
	level.name = "LevelRoot"
	floors.name = "Floors"
	walls.name = "Walls"
	enemies.name = "Enemies"
	pickups.name = "Pickups"
	
	# Clear valid spawn positions
	valid_spawn_positions.clear()
	
	# Adjust parameters based on difficulty
	match Settings.last_difficulty:
		LevelManager.Difficulties.EASY:
			map_width = randi_range(8, 12)
			map_height = randi_range(8, 12)
			enemy_count = randi_range(3, 7)
			pickup_count = randi_range(2, 4)
			ammo_count = randi_range(2, 4)
		LevelManager.Difficulties.NORMAL:
			map_width = randi_range(13, 17)
			map_height = randi_range(13, 17)
			enemy_count = randi_range(8, 12)
			pickup_count = randi_range(4, 6)
			ammo_count = randi_range(2, 5)
		LevelManager.Difficulties.HARD:
			map_width = randi_range(18, 22)
			map_height = randi_range(18, 22)
			enemy_count = randi_range(13, 17)
			pickup_count = randi_range(6, 8)
			ammo_count = randi_range(2, 6)
	
	# Generate floor and store valid spawn positions
	for x: int in range(map_width):
		for y: int in range(map_height):
			var floor_tile := floorScene.instantiate() # Instantiate the floor scene
			LevelManager.floorCount += 1
			floor_tile.position = Vector3(x * tile_size, 0, y * tile_size)
			floor_tile.name = "Floor" + str(LevelManager.floorCount)
			floors.add_child(floor_tile)
			print("Added floor tile at: ", floor_tile.position)
			
			# Add position to valid spawn positions (exclude perimeter to avoid walls)
			if x > 0 and x < map_width - 1 and y > 0 and y < map_height - 1:
				valid_spawn_positions.append(Vector3(x * tile_size, 1, y * tile_size))
	
	# Generate perimeter walls
	for x: int in range(map_width):
		for y: int in [0, map_height - 1]:
			var wall := wallScene.instantiate() # Instantiate the wall scene
			LevelManager.wallCount += 1
			wall.name = "Wall" + str(LevelManager.wallCount)
			wall.position = Vector3(x * tile_size, 1, y * tile_size)
			walls.add_child(wall)
			print("Added wall section at: ", wall.position)
	for y: int in range(map_height):
		for x: int in [0, map_width - 1]:
			var wall := wallScene.instantiate() # Instantiate the wall scene
			LevelManager.wallCount += 1
			wall.name = "Wall" + str(LevelManager.wallCount)
			wall.position = Vector3(x * tile_size, 1, y * tile_size)
			walls.add_child(wall)
			print("Added wall section at: ", wall.position)
	
	# Spawn enemies
	for i: int in range(enemy_count):
		var enemy: Node = enemyScenes[Settings.enemy_to_use].instantiate() # Instantiate the enemy scene
		LevelManager.enemyCount += 1
		enemy.name = "Enemy" + str(LevelManager.enemyCount)
		enemy.position = get_random_position()
		enemy.player = player
		enemies.add_child(enemy)
		print("Added enemy at: ", enemy.position)
	
	# Spawn health pickups
	for i: int in range(pickup_count):
		var pickup := hpScene.instantiate() # Instantiate the health pickup scene
		LevelManager.healthPickups += 1
		pickup.name = "HP" + str(LevelManager.healthPickups)
		pickup.position = get_random_position()
		pickups.add_child(pickup)
		print("Added health pickup at: ", pickup.position)
	
	# Spawn ammo pickups
	for i: int in range(ammo_count):
		var ammo := ammoScene.instantiate() # Instantiate the ammo pickup scene
		LevelManager.ammoPickups += 1
		ammo.name = "Ammo" + str(LevelManager.ammoPickups)
		ammo.position = get_random_position()
		pickups.add_child(ammo)
		print("Added ammo pickup at: ", ammo.position)

	# Center player
	player.position = Vector3(map_width * tile_size / 2, 1, map_height * tile_size / 2)
	player.hud = hud # Make the hud accessible to the player
	
	# Add all the generated nodes to the level
	level.add_child(floors)
	level.add_child(walls)
	level.add_child(enemies)
	level.add_child(pickups)
	level.add_child(player)
	level.add_child(hud)
	
	# Send the generated level to the LevelManager
	return level


# Called to find a random position to place enemies and pickups
func get_random_position() -> Vector3:
	if valid_spawn_positions.is_empty():
		return Vector3(1 * tile_size, 1, 1 * tile_size)  # Fallback position
	var index: int = randi() % valid_spawn_positions.size()
	var pos: Vector3 = valid_spawn_positions[index]
	# Optionally remove the position to prevent overlap
	valid_spawn_positions.remove_at(index)
	return pos
