extends State

@export var return_state: State
@onready var attack_area: AttackArea = $"../../AttackArea"
@onready var timer: Timer = $Timer


func on_enter() -> void:
	character.deceleration = 20.0


func state_process(_delta: float) -> void:
	if InputPackage.is_pressed("light_attack") or InputPackage.is_held("light_attack"):
		timer.start()
#FIXME: skiping animations
	var current_anim = playback.get_current_node()
	if not timer.is_stopped():
		match current_anim:
			"light_attack_reco_1":
				playback.travel("light_attack_2")
				timer.stop()
			"light_attack_reco_2":
				playback.travel("light_attack_3")
				timer.stop()


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "light_attack_1":
		if timer.is_stopped():
			playback.travel("light_attack_reco_1")
		else:
			playback.travel("light_attack_2")

	if anim_name == "light_attack_reco_1":
		next_state = return_state

	if anim_name == "light_attack_2":
		if timer.is_stopped():
			playback.travel("light_attack_reco_2")
		else:
			playback.travel("light_attack_3")

	if anim_name == "light_attack_reco_2":
		next_state = return_state

	if anim_name == "light_attack_3":
		playback.travel("light_attack_reco_3")
	if anim_name == "light_attack_reco_3":
		next_state = return_state


func calculate_damage(raw_damage: int) -> void:
	attack_area.damage = raw_damage + character.stats.current_attack
