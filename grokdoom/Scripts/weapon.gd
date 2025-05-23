class_name Weapon extends Node3D

enum weapons {
	PISTOL,
	SHOTGUN
}

@export var weaponType := weapons.PISTOL
var damage := 10
var fire_rate := 0.5
var fireTimer := 0.0
var can_fire := true
@onready var player: CharacterBody3D = find_parent("Player")
@onready var ray := $RayCast3D


# Called when the node enters the scene tree for the first time
func _ready():
	if weaponType == weapons.SHOTGUN:
		damage = 5  # Per pellet
		fire_rate = 1.0


# Called ever render frame
func _process(delta):
	if !can_fire:
		if fireTimer < fire_rate:
			fireTimer += delta
		else:
			can_fire = true
			fireTimer = 0
	
	if Input.is_action_just_pressed("fire") and can_fire:
		fire()


# Called to fire the selected weapon
func fire():
	can_fire = false
	match [ weaponType, player.currentWeapon ]:
		# Pistol
		[ weapons.PISTOL, weapons.PISTOL ]:
			ray.force_raycast_update()
			if ray.is_colliding():
				var target = ray.get_collider()
				if target.is_in_group("enemies"):
					# TODO: Play a pistol fire sound
					doDamage(target)
					print("Fired pistol at ", target.name, " for ", damage, " damage.")
		
		# Shotgun
		[weapons.SHOTGUN, weapons.SHOTGUN ]:
			# If player is out of shotgun ammo, exit early
			if player.shotgun_ammo <= 0:
				# TODO: Play an out of ammo sound, like an empty-feeling "click"
				print("Out of ammo!")
				return
			# Otherwise, blast that thing!
			else:
				player.shotgun_ammo -= 1
				var target: Node
				var totalDmg := 0
				for i: int in range(5):  # 5 pellets per shell
					ray.rotation_degrees = Vector3(randf_range(-5, 5), randf_range(-5, 5), 0)
					ray.force_raycast_update()
					if ray.is_colliding():
						target = ray.get_collider()
						if target.is_in_group("enemies"):
							doDamage(target)
							totalDmg += damage
							# TODO: Play a shotgun fire sound
				print("Fired shotgun at ", target.name, " for ", totalDmg, " damage.")
	player.update_hud()  # Update HUD after ammo change


# Called to damage the enemy target
func doDamage(target) -> void:
	target.health -= damage
	if target.health <= 0:
		print("Enemy killed: ", target.name)
		target.healthReachedZero()
