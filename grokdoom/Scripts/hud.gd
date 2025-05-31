class_name HUD extends CanvasLayer

func update_health(health):
	$HealthLabel.text = "Health: " + str(health)

func update_weapon(weapon):
	$WeaponLabel.text = "Weapon: " + weapon

func update_ammo(ammo):
	if ammo == -1:  # -1 represents infinite ammo (pistol)
		$AmmoLabel.text = "Ammo: ∞"
	else:
		$AmmoLabel.text = "Ammo: " + str(ammo)
