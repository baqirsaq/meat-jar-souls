extends State

@export var air_state: State
@export var sprint_state: State
@export var light_attack_state: State
@export var guard_state: State
@export var jump_power: float = -800.0
@export var speed: float = 400.0
@export var ground_acceleration: float = 200.0
@export var ground_deceleration: float = 100.0
var coyote_time: float = 0.2  # in seconds
var time_passed: float = 0.0


func on_enter() -> void:
	time_passed = 0.0
	character.speed = speed
	character.acceleration = ground_acceleration
	character.deceleration = ground_deceleration


func state_process(delta: float) -> void:
	if not character.is_on_floor():
		_handle_coyote_time(delta)
	else:
		if InputPackage.is_pressed("jump"):
			playback.travel("jump_start")
		if InputPackage.is_held("sprint"):
			_sprint()
		if InputPackage.is_pressed("light_attack"):
			_light_attack()
		if InputPackage.is_held("guard"):
			_guard()


func _guard() -> void:
	next_state = guard_state
	playback.travel("parry")


func _light_attack() -> void:
	next_state = light_attack_state
	playback.travel("light_attack_1")

func _sprint() -> void:
	next_state = sprint_state
	playback.travel("sprint")


func _handle_coyote_time(delta: float) -> void:
	if time_passed < coyote_time:
		time_passed += delta
		if InputPackage.is_pressed("jump"):
			playback.travel("jump_start")
	else:
		next_state = air_state


func handle_jump() -> void:
	character.velocity.y = jump_power
	next_state = air_state
