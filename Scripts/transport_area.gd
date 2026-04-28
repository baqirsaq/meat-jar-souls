extends Node2D

@export_file("*.tscn") var next_scene_path: String


func _on_area_2d_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file(next_scene_path)


func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	get_tree().change_scene_to_file(next_scene_path)
