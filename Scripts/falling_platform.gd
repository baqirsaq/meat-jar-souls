extends StaticBody2D

@onready var timer: Timer = $Timer
var is_falling: bool = false

func _physics_process(delta: float) -> void:
	# Logic: Only fall if the timer HAS finished (or was triggered)
	# and we have set the falling flag to true.
	if is_falling:
		position.y += 980 * delta

func _on_timer_timeout() -> void:
	# This is the key: The platform starts falling ONLY after the timer ends
	is_falling = true

func _on_dectection_area_body_entered(_body: Node2D) -> void:
	# Start the countdown when the player touches it
	if timer.is_stopped() and !is_falling:
		timer.start()

# --- OFF-SCREEN DELETION ---
# 1. Add a "VisibleOnScreenNotifier2D" node as a child of your platform.
# 2. Connect its "screen_exited" signal to this function:
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
