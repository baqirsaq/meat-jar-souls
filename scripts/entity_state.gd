class_name EntityState
extends Node

enum State { GROUNDED, AIRBORNE, BUSY, LOCKED }
var current_state: State = State.AIRBORNE


func update_physics_state(is_on_floor: bool) -> void:
	if current_state == State.BUSY or current_state == State.LOCKED:
		return

	if is_on_floor and current_state != State.GROUNDED:
		_change_state(State.GROUNDED)
	elif !is_on_floor and current_state != State.AIRBORNE:
		_change_state(State.AIRBORNE)



func _change_state(new_state: State) -> void:
	#print("State changed to: ", State.keys()[new_state])
	current_state = new_state


func set_state(new_state: State) -> void:
	current_state = new_state
