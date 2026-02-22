extends State

@export var ground_state: State
@export var guard_speed: float = 250.0
@onready var damage_area: DamageArea = $"../../DamageArea"
var is_parry_done: bool = false

func on_enter() -> void:
	is_parry_done = false
	character.speed = guard_speed
	character.acceleration = ground_state.ground_acceleration
	character.deceleration = ground_state.ground_deceleration


func state_process(_delta: float) -> void:
	if not InputPackage.is_held("guard") and is_parry_done:
		next_state = ground_state
		playback.travel("move")



func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "parry":
		is_parry_done = true


func on_exit() -> void:
	damage_area.set_defense_state(DamageArea.DefenseState.NONE)
