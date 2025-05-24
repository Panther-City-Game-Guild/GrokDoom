extends Node

# Level Construction Parameters
var tile_size := 2.0
var map_width := 10
var map_height := 10
var enemy_count := 5
var pickup_count := 3
var ammo_count := 2
var valid_spawn_positions: Array[Vector3] = []  # Store valid spawn positions


# Called to generate a level
func generate_level(difficulty: LevelManager.difficulties)-> void:
	# Clear valid spawn positions
	valid_spawn_positions.clear()
	
	# Adjust parameters based on difficulty
	match difficulty:
		LevelManager.difficulties.EASY:
			map_width = randi_range(8, 12)
			map_height = randi_range(8, 12)
			enemy_count = randi_range(3, 7)
			pickup_count = randi_range(2, 4)
			ammo_count = randi_range(2, 4)
		LevelManager.difficulties.NORMAL:
			map_width = randi_range(13, 17)
			map_height = randi_range(13, 17)
			enemy_count = randi_range(8, 12)
			pickup_count = randi_range(4, 6)
			ammo_count = randi_range(2, 5)
		LevelManager.difficulties.HARD:
			map_width = randi_range(18, 22)
			map_height = randi_range(18, 22)
			enemy_count = randi_range(13, 17)
			pickup_count = randi_range(6, 8)
			ammo_count = randi_range(2, 6)
	
	# Generate floor and store valid spawn positions
	for x: int in range(map_width):
		for y: int in range(map_height):
			var floor_tile := preload("res://Scenes/Floor.tscn").instantiate()
			LevelManager.floorCount += 1
			floor_tile.position = Vector3(x * tile_size, 0, y * tile_size)
			floor_tile.name = "Floor" + str(LevelManager.floorCount)
			LevelManager.nextLevel.add_child(floor_tile)
			print("Added floor tile at: ", floor_tile.position)
			
			# Add position to valid spawn positions (exclude perimeter to avoid walls)
			if x > 0 and x < map_width - 1 and y > 0 and y < map_height - 1:
				valid_spawn_positions.append(Vector3(x * tile_size, 1, y * tile_size))
	
	# Generate perimeter walls
	for x: int in range(map_width):
		for y: int in [0, map_height - 1]:
			var wall := preload("res://Scenes/Wall.tscn").instantiate()
			LevelManager.wallCount += 1
			wall.name = "Wall" + str(LevelManager.wallCount)
			wall.position = Vector3(x * tile_size, 1, y * tile_size)
			LevelManager.nextLevel.add_child(wall)
			print("Added wall section at: ", wall.position)
	for y: int in range(map_height):
		for x: int in [0, map_width - 1]:
			var wall := preload("res://Scenes/Wall.tscn").instantiate()
			LevelManager.wallCount += 1
			wall.name = "Wall" + str(LevelManager.wallCount)
			wall.position = Vector3(x * tile_size, 1, y * tile_size)
			LevelManager.nextLevel.add_child(wall)
			print("Added wall section at: ", wall.position)
	
	# Spawn enemies
	for i: int in range(enemy_count):
		#var enemy := preload("res://Scenes/Enemy.tscn").instantiate()
		var enemy := preload("res://Scenes/ZombieEnemy.tscn").instantiate()
		LevelManager.enemyCount += 1
		enemy.name = "Enemy" + str(LevelManager.enemyCount)
		enemy.position = get_random_position()
		LevelManager.nextLevel.add_child(enemy)
		print("Added enemy at: ", enemy.position)
	
	# Spawn health pickups
	for i: int in range(pickup_count):
		var pickup := preload("res://Scenes/HealthPickup.tscn").instantiate()
		LevelManager.healthPickups += 1
		pickup.name = "HP" + str(LevelManager.healthPickups)
		pickup.position = get_random_position()
		LevelManager.nextLevel.add_child(pickup)
		print("Added health pickup at: ", pickup.position)
	
	# Spawn ammo pickups
	for i: int in range(ammo_count):
		var ammo := preload("res://Scenes/AmmoPickup.tscn").instantiate()
		LevelManager.ammoPickups += 1
		ammo.name = "Ammo" + str(LevelManager.ammoPickups)
		ammo.position = get_random_position()
		LevelManager.nextLevel.add_child(ammo)
		print("Added ammo pickup at: ", ammo.position)
	
	# Center player
	var player: CharacterBody3D = LevelManager.nextLevel.get_node("Player")
	player.position = Vector3(map_width * tile_size / 2, 1, map_height * tile_size / 2)


# Called to find a random position to place enemies and pickups
func get_random_position() -> Vector3:
	if valid_spawn_positions.is_empty():
		return Vector3(1 * tile_size, 1, 1 * tile_size)  # Fallback position
	var index: int = randi() % valid_spawn_positions.size()
	var pos: Vector3 = valid_spawn_positions[index]
	# Optionally remove the position to prevent overlap
	valid_spawn_positions.remove_at(index)
	return pos
