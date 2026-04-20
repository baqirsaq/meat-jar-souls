class_name EnemyAI
extends Character

@onready var ray_cast: RayCast2D = $RayCast2D

enum States {
	IDLE,
	CHASE,
	ATTACK
}

var current_state = States.IDLE
var player: Player = null
var in_line_of_sight: bool = false

func _ready() -> void:
	speed = 100

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity.y -= 980
	
	match States:
		States.IDLE:
			if player and is_instance_valid(player):
				if is_player_in_los():
					current_state = States.CHASE
		States.CHASE:
			print("followsSssstsa")
			velocity.x = lerp(position.x, player.position.x, speed)
			if not is_player_in_los():
				current_state = States.IDLE
		States.ATTACK:
			pass


func _in_view_range(_body: Node2D) -> void: # connects to area2d
	if player and is_instance_valid(player):
		ray_cast.target_position = ray_cast.to_local(player.global_position)

		ray_cast.force_raycast_update()


func is_player_in_los() -> bool:
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()

		return collider is Player
	return false


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null
