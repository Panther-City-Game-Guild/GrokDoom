class_name ZombierEnemy extends Enemy

@onready var animation_player = $ZombieEnemyModel/AnimationPlayer
@onready var hit_area = $ZombieEnemyModel/HitArea
var is_attacking = false
var is_walking = false


# Called when node first enters the scene tree
func _ready() -> void:
	super() # call the base class _ready() function
	speed = randf_range(.5, 1) # Random movement speed, never "quite" as fast as the player (3.0)
	health = randi_range(10, 50)  # Random amount of health
	damage = randi_range(1, 10) # Random amount of damage to do to the player
	atkDelay = randf_range(1.0, 5.0) # Random amount of delay between attacks
	atkTimer = 0.0 # Count how long since last attack
	atkRange = 1.5 # Maximum distance from player before enemy can attack
	canAtk = false # Flag to determine if the enemy is able to attack
	scalar = 1.0
	if animation_player.has_animation("Animations/ZombieIdle"):
		animation_player.play("Animations/ZombieIdle")
	else:
		print("Warning: 'ZombieIdle' animation not found")
	
	# Connect the hit signal from HitArea
	hit_area.hit.connect(_on_hit)


# Called every render frame - NOTE: This is here to serve as an override for the Enemy _process function
func _process(_delta: float) -> void:
	return

# Called every physics frame (60 FPS)
func _physics_process(_delta) -> void:
	if not player:
		return
	
	var direction = (player.global_position - global_position).normalized()
	direction.y = 0
	
	var distance = global_position.distance_to(player.global_position) # Enemy base class already has a variable called distance_to_player that this class could make use of
	
	if distance <= atkRange and not is_attacking:
		is_attacking = true
		if animation_player.has_animation("Animations/ZombieAttack"):
			animation_player.play("Animations/ZombieAttack")
		attack_player()
	elif distance > atkRange and is_attacking:
		is_attacking = false
		if animation_player.has_animation("Animations/ZombieWalkInPlace"):
			animation_player.play("Animations/ZombieWalkInPlace")
			is_walking = true;
	
	if not is_attacking:
		if not is_walking:
			if animation_player.has_animation("Animations/ZombieWalkInPlace"):
				animation_player.play("Animations/ZombieWalkInPlace")
				is_walking = true;
		velocity = direction * speed
		move_and_slide()
		var look_at_pos = player.global_position
		look_at_pos.y = global_position.y
		look_at(look_at_pos, Vector3.UP)


# NOTE: Currently unused - (Would be) Called by HitArea attached to the ZombieEnemyModel node to do damage to the enemy
# NOTE: Damage is also being handled by the Player class for the Pistol and Shotgun (possibly violating the "Call Down, Signal Up" pattern of Godot)
func _on_hit():
	health -= damage
	print("Zombie hit! Health: ", health)
	if health <= 0:
		if animation_player.has_animation("Animations/ZombieFallBack"):
			animation_player.play("Animations/ZombieFallBack")
		set_physics_process(false)  # Stop movement
		# Optionally queue_free() to remove the zombie after the death animation


# Called by the player to tell the enemy it died (see enemy.gd for more insight)
func healthReachedZero() -> void:
	super() # call the base class healthReachedZero() function
	if animation_player.has_animation("Animations/ZombieFallBack"):
		animation_player.play("Animations/ZombieFallBack")
