extends State

@export var ground_state: State
@export var landing_state: State
@export var heavly_landing_threshold: float = 500

func state_process(delta: float) -> void:
	if character.velocity.y > 0.0:
		playback.travel("jump_end")
	
	if character.is_on_floor():
		
		_handle_heavy_landing()
		
		playback.travel("move")
		next_state = ground_state


func _handle_heavy_landing() -> void:
	if heavly_landing_threshold <= character.velocity.y:
		playback.travel("heavy_land")
		next_state = landing_state
