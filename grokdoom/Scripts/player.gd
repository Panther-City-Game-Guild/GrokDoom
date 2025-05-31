class_name Player extends CharacterBody3D


@export var currentWeapon := Weapon.weapons.PISTOL
@export var speed := 5.0
@export var health := 100
@export var shotgun_ammo := 5  # Starting with 5 shells
@onready var pistol := $WeaponHolder/Pistol
@onready var shotgun := $WeaponHolder/Shotgun
var hud: CanvasLayer


# Called when the node enters the scene tree for the first time
func _ready() -> void:
	self.add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_hud()


# Called when input event is detected
func _input(event) -> void:
	# Mouse movement; player rotation
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * Settings.mouse_look))
	
	# Switching weapons
	if event.is_action_pressed("weapon_switch"):
		match currentWeapon:
			Weapon.weapons.PISTOL:
				currentWeapon = Weapon.weapons.SHOTGUN
				pistol.visible = false
				shotgun.visible = true
			Weapon.weapons.SHOTGUN:
				currentWeapon = Weapon.weapons.PISTOL
				shotgun.visible = false
				pistol.visible = true
		update_hud()
		print("Current Weapon: ", currentWeapon)
		print("Visibility (Pistol): ", pistol.visible, ", (Shotgun): ", shotgun.visible)


# Called every physics frame (60 FPS)
func _physics_process(_delta) -> void:
	var direction := Vector3.ZERO	
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()


# Called to update the HUD
func update_hud() -> void:
	var weaponName := ""
	if currentWeapon == Weapon.weapons.PISTOL: weaponName = "Pistol"
	if currentWeapon == Weapon.weapons.SHOTGUN: weaponName = "Shotgun"
	hud.update_health(health)
	hud.update_weapon(weaponName)
	hud.update_ammo(-1 if currentWeapon == Weapon.weapons.PISTOL else shotgun_ammo)


# Called when a player's health should change (pickup healthkit or take damage)
func change_health(amount) -> void:
	health += amount
	if health > 100:
		health = 100
	elif health < 0:
		health = 0  # Optionally add game over logic here
	update_hud()


# Called when player picks up ammo
func add_ammo(amount) -> void:
	shotgun_ammo += amount
	update_hud()
