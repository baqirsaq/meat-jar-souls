@icon("uid://eahu0x280ad7")
class_name State
extends Node

## The base class for all character states.
## Manages entry, exit, and per-frame logic.

@export var can_move: bool = true

var character: Character
var playback: AnimationNodeStateMachinePlayback
var next_state: State

# ====================
# VIRTUAL METHODS
# ====================


## Called when the CharacterStateMachine switches to this state.
func on_enter() -> void:
	pass


## Called when the CharacterStateMachine switches away from this state.
func on_exit() -> void:
	pass


## Handles input events specifically for this state.
func state_input(_event: InputEvent) -> void:
	pass
