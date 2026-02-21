extends State

@export var return_state: State
@onready var timer: Timer = $Timer


func state_process(_delta: float) -> void:
	# 1. Always buffer the input by starting the timer
	if InputPackage.is_pressed("light_attack") or InputPackage.is_held("light_attack"):
		timer.start()

	# 2. Check if we are CURRENTLY in a recovery animation
	var current_anim = playback.get_current_node()

	# 3. If in recovery and timer is running (player just pressed attack), skip to next attack
	if not timer.is_stopped():
		match current_anim:
			"light_attack_reco_1":
				playback.travel("light_attack_2")
				timer.stop() # Clear the buffer so it doesn't double-trigger
			"light_attack_reco_2":
				playback.travel("light_attack_3")
				timer.stop()
			"light_attack_reco_3":
				playback.travel("light_attack_1") # Loop back or reset
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
		if timer.is_stopped():
			playback.travel("light_attack_reco_3")
		else:
			playback.travel("light_attack_3")

	if anim_name == "light_attack_reco_3":
		next_state = return_state
