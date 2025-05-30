extends CharacterBody3D

var speed := randf_range(.5, 1) # Random movement speed, never "quite" as fast as the player (3.0)
var health := randi_range(10, 50)  # Random amount of health
var damage := randi_range(1, 10) # Random amount of damage to do to the player
var atkDelay := randf_range(1.0, 5.0) # Random amount of delay between attacks
var killPoints := 0 # The number of points this enemy is worth when killed
var atkRange := 1.5 # Maximum distance from player before enemy can attack
var atkTimer := 0.0 # Count how long since last attack
var canAtk := false # Flag to determine if the enemy is able to attack
var distance_to_player := 3.0 # Current distance from the player
var player: CharacterBody3D # A handle to the player
var scalar := 1.0
var limp_amplitude: float = 0.15  # Max tilt angle in radians for the limp
var limp_frequency: float = 2.0   # Speed of the limp cycle (higher = faster limp)

# Called when the node first enters the scene tree
func _ready():
	self.add_to_group("enemies")
	player = get_node("../Player")
	killPoints = calcScoreValue()


# Called every render frame
func _process(delta: float) -> void:
	if !is_physics_processing():
		global_rotation_degrees -= Vector3(speed / atkDelay, health / atkDelay, damage / atkDelay)
		if scalar > 0.01:
			scalar -= delta
		scale = Vector3(scalar, scalar, scalar)
		if atkTimer < atkDelay:
			atkTimer += delta
		else:
			queue_free()


# Called every physics frame (60 FPS, regardless of frame rate)
func _physics_process(delta):
	if player:
		var direction := (player.global_transform.origin - global_transform.origin).normalized()
		
		# Face the player Detailed method(rotate around Y-axis only to keep zombie upright)
		#if direction.length() > 0:  # Ensure direction is not zero to avoid division errors
		#	var angle = atan2(direction.x, direction.z)  # Angle in radians around Y-axis
		#	rotation = Vector3(0, angle, 0)  # Rotate only around Y to face the player
		
		# Face the player Simple method
		look_at(player.global_transform.origin, Vector3.UP)
		
		#Limp
		if velocity.length() > 0:
			var limp_angle = sin(Time.get_ticks_msec() * 0.001 * limp_frequency) * limp_amplitude
			rotation.z = limp_angle  # Tilt side-to-side to simulate limping

		velocity = direction * speed
		move_and_slide()
		
		# If enough time has elapsed since the last attack, try to attack
		if atkTimer >= atkDelay:
			# Check if player is within attack range
			distance_to_player = global_transform.origin.distance_to(player.global_transform.origin)
			canAtk = distance_to_player <= atkRange
			
			# If possible to do so, attack the player
			if canAtk:
				attack_player()
				atkTimer = 0.0
		else:
			atkTimer += delta


# Called to attack the player by telling the player to decrease its health
func attack_player() -> void:
	player.change_health(-damage)


func calcScoreValue() -> int:
	return roundi((speed + health + damage + atkDelay) / 4)


func healthReachedZero() -> void:
	LevelManager.changeScore(killPoints)
	collision_layer = 0
	set_physics_process(false)
	atkTimer = 0.0
