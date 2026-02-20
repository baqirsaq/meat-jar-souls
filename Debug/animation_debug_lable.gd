extends Label

@export var animation_tree: AnimationTree

func _process(_delta: float) -> void:
	if not animation_tree:
		text = "No AnimationTree Assigned"
		return

	var playback = animation_tree.get("parameters/playback")

	if playback:
		var current_node = playback.get_current_node()
		text = "State: " + str(current_node)
	else:
		text = "Error: Could not find Playback"
