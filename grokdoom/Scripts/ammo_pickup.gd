extends Area3D

@export var min_ammo_add := 3  # As few as 3 shells
@export var max_ammo_add := 5  # As many as 5 shells

func _on_body_entered(body: Node3D):
	if body.name == "Player":
		body.add_ammo(randi_range(min_ammo_add, max_ammo_add))
		queue_free()
