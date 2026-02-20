extends Node
class_name State

## The base class for all character states. 
## Manages entry, exit, and per-frame logic.

@export var can_move: bool = true

var character: CharacterBody2D
var playback: AnimationNodeStateMachinePlayback
var next_state: State

# ====================
# VIRTUAL METHODS
# ====================


## Handles physics or frame processing.
func state_process(delta: float) -> void:
	pass


## Called when the CharacterStateMachine switches to this state.
func on_enter() -> void:
	pass


## Called when the CharacterStateMachine switches away from this state.
func on_exit() -> void:
	pass


## Handles input events specifically for this state.
func state_input(event: InputEvent) -> void:
	pass
