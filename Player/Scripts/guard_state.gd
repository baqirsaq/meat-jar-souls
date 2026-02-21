extends State

@export var ground_state: State
@export var guard_speed: float = 200.0


func on_enter() -> void:
    character.speed = guard_speed
    character.acceleration = ground_state.ground_acceleration
    character.deceleration = ground_state.ground_deceleration


func _handle_animations() -> void:
    if character.velocity.x == 0:
        playback.travel("idle_parry")
    else:
        playback.travel("run_parry")