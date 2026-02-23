#TODO: make it look good 
extends GPUParticles2D
@onready var animation_player1: AnimationPlayer = $BloodAnimations/AnimationPlayer
@onready var animation_player2: AnimationPlayer = $BloodAnimations2/AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func blood_start():
	animation_player1.play("blood_1")
	animation_player2.play("blood_2")
