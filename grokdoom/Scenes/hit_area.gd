extends Area3D
# Define the custom hit signal with a damage parameter
signal hit(damage)

func _ready():
	# Connect built-in Area3D signals to detect collisions
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _on_area_entered(area: Area3D):
	# Check if the colliding area is a bullet or attack (e.g., in "bullet" group)
	if area.is_in_group("bullet"):
		# Get damage from the bullet (default to 10 if not specified)
		var damage = area.get("damage") if area.has_meta("damage") else 10
		emit_signal("hit", damage)

func _on_body_entered(body: Node3D):
	# Check if the colliding body is a bullet or attack (e.g., a RigidBody3D projectile)
	if body.is_in_group("bullet"):
		var damage = body.get("damage") if body.has_meta("damage") else 10
		emit_signal("hit", damage)
