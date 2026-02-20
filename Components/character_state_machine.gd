class_name CharacterStateMachine
extends Node

## Manages the switching and execution of character states.

@export var character: Character
@export var animation_tree: AnimationTree
@export var initial_state: State

var current_state: State
var states: Array[State] = []

# ====================
# GODOT CALLBACKS
# ====================

func _ready() -> void:
	await owner.ready
	_init_states()


func _physics_process(delta: float) -> void:
	if not current_state:
		return

	if current_state.next_state:
		switch_state(current_state.next_state)

	current_state.state_process(delta)


func _input(event: InputEvent) -> void:
	if current_state:
		current_state.state_input(event)

# ====================
# PUBLIC API
# ====================

## Returns whether the current state allows the character to move.
func can_move() -> bool:
	return current_state.can_move if current_state else false


## Logic for exiting the old state and entering the new one.
func switch_state(new_state: State) -> void:
	if current_state:
		current_state.on_exit()
		current_state.next_state = null

	current_state = new_state
	current_state.on_enter()

# ====================
# PRIVATE FUNCTIONS
# ====================

func _init_states() -> void:
	for child in get_children():
		if child is State:
			states.append(child)
			child.character = character
			child.playback = animation_tree["parameters/playback"]
		else:
			push_warning("Child '%s' is not a State node." % child.name)

	if initial_state:
		switch_state(initial_state)
	elif states.size() > 0:
		switch_state(states[0])
