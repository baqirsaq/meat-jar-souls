extends CanvasLayer

# Drag and drop your images into this array in the Inspector
@export var pages: Array[Texture2D] = []
@export_file("*.tscn") var next_scene_path: String

var current_page: int = 0

@onready var display = $ComicDisplay

func _ready():
	update_page()

func update_page():
	if pages.size() > 0:
		display.texture = pages[current_page]
	
	# Optional: Hide back button on first page
	$BackButton.visible = current_page > 0

func _on_forward_button_pressed():
	if current_page < pages.size() - 1:
		current_page += 1
		update_page()
	else:
		# We reached the end!
		get_tree().change_scene_to_file(next_scene_path)

func _on_back_button_pressed():
	if current_page > 0:
		current_page -= 1
		update_page()
