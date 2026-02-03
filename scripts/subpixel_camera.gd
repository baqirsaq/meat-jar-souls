extends Camera2D

@export var Target: CharacterBody2D 
var actual_camera_position: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	actual_camera_position = actual_camera_position.lerp(Target.global_position, delta * 3)
	
	var camera_subpixel_offset: Vector2 = actual_camera_position.round() - actual_camera_position
	
	get_parent().get_parent().get_parent().material.set_shader_parameter("cam_offset", camera_subpixel_offset)
	
	global_position = actual_camera_position.round()
