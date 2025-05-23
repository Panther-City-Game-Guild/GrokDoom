extends Area3D

@export var health_amount := 20

func _on_body_entered(body: Node3D):
	if body.name == "Player":
		body.change_health(health_amount)
		queue_free()
