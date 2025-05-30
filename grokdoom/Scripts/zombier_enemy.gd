extends CharacterBody3D

@onready var character_body = self
@onready var animation_player = $ZombieEnemyModel/AnimationPlayer
@onready var hit_area = $ZombieEnemyModel/HitArea
@onready var player = get_tree().get_first_node_in_group("player")

var attack_range = 1.5
var is_attacking = false
var is_walking = false
var speed := randf_range(.5, 1) # Random movement speed, never "quite" as fast as the player (3.0)
var health := randi_range(10, 50)  # Random amount of health
var damage := randi_range(1, 10) # Random amount of damage to do to the player
var atkDelay := randf_range(1.0, 5.0) # Random amount of delay between attacks
var killPoints := 0 # The number of points this enemy is worth when killed
var atkTimer := 0.0 # Count how long since last attack
var canAtk := false # Flag to determine if the enemy is able to attack
var distance_to_player := 3.0 # Current distance from the player
var scalar := 1.0

func _ready():
	self.add_to_group("enemies")
	player = get_node("../Player")
	killPoints = calcScoreValue()
	if animation_player.has_animation("Animations/ZombieIdle"):
		animation_player.play("Animations/ZombieIdle")
	else:
		print("Warning: 'ZombieIdle' animation not found")
	
	# Connect the hit signal from HitArea
	hit_area.hit.connect(_on_hit)

func calcScoreValue() -> int:
	return roundi((speed + health + damage + atkDelay) / 4)

func _physics_process(delta):
	if not player:
		return

	var direction = (player.global_position - character_body.global_position).normalized()
	direction.y = 0

	var distance = character_body.global_position.distance_to(player.global_position)

	if distance <= attack_range and not is_attacking:
		is_attacking = true
		if animation_player.has_animation("Animations/ZombieAttack"):
			animation_player.play("Animations/ZombieAttack")
	elif distance > attack_range and is_attacking:
		is_attacking = false
		if animation_player.has_animation("Animations/ZombieWalkInPlace"):
			animation_player.play("Animations/ZombieWalkInPlace")
			is_walking = true;

	if not is_attacking:
		if not is_walking:
			if animation_player.has_animation("Animations/ZombieWalkInPlace"):
				animation_player.play("Animations/ZombieWalkInPlace")
				is_walking = true;
		character_body.velocity = direction * speed
		character_body.move_and_slide()
		var look_at_pos = player.global_position
		look_at_pos.y = character_body.global_position.y
		character_body.look_at(look_at_pos, Vector3.UP)

func _on_hit(damage: float):
	health -= damage
	print("Zombie hit! Health: ", health)
	if health <= 0:
		if animation_player.has_animation("Animations/ZombieFallBack"):
			animation_player.play("Animations/ZombieFallBack")
		set_physics_process(false)  # Stop movement
		# Optionally queue_free() to remove the zombie after the death animation

func healthReachedZero():
	if animation_player.has_animation("Animations/ZombieFallBack"):
		animation_player.play("Animations/ZombieFallBack")
	set_physics_process(false)  # Stop movement
