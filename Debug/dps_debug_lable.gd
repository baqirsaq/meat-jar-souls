extends Label

var total_damage_received: float = 0.0
var session_start_time: float = 0.0

func _ready() -> void:
	session_start_time = Time.get_unix_time_from_system()
	text = "Damage: 0 | DPS: 0"


func _on_damage_area_on_hit_received(attack_area: AttackArea, defense_state: DamageArea.DefenseState) -> void:
	var incoming_damage: float = attack_area.damage
	
	total_damage_received += incoming_damage
	var current_time = Time.get_unix_time_from_system()
	var elapsed = current_time - session_start_time
	
	# Avoid division by zero if hit on the very first frame
	var dps = total_damage_received / max(elapsed, 1.0)

	# 4. Update the UI text
	text = "Last Hit: %d | Total: %d | DPS: %.2f" % [incoming_damage, total_damage_received, dps]
