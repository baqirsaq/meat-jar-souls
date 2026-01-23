class_name Player
extends CharacterBody2D
#TODO:
# add horizontal wallrun & wallkicks (titanfall style)
# add wall clime and stamina
# add ledge grab

enum PlayerState { IDLE, RUN, SLIDE, CROUCH, WALL_BOUNCE, WALL_SLIDE, AIR_MOVEMENT }

#region CONSTANTS
# JUMP
const JUMP_HEIGHT: float = -650.0
## how fast does the jump stop after it cut, makes the transition really smooth
const JUMP_CUT_POWER: float = 0.5
## only assist movement when moving upward significant
const JUMP_ASSIST_THRESHOLD: float = JUMP_HEIGHT / 2.0
const JUMP_SLIDE_MULTIPLIER: float = 0.50

# AIR MOVEMENT
const HEAD_NUDGE_POWER: float = 20.00
const LEDGE_BOOST_POWER: float = 200.0
const MIN_LEDGE_BOOST_VELOCITY = -30.0
const MAX_LEDGE_BOOST_VELOCITY = -5.0
const MAX_LURCH_SPEED: float = 300.0
const LURCH_STEP: float = 50.0

# GROUND MOVEMENT
const MAX_RUN_SPEED: float = 600.0
const MAX_CROUCH_SPEED: float = 200.0
const GROUND_ACCELERATION: float = 30.0
const FRICTION: float = 20.0
const SLIDE_FRICTION: float = 1.0
## multiplies the players x velocity by 1.75, 1.2, and 1.2 every successive slide
const SLIDE_BOOST_POWER: Array = [1.5, 1.2, 1.2]
## shrink the collision height
const SLIDE_Y_SCALE: float = 0.5
const SLIDE_Y_OFFSET: float = 8.0

# WALL INTERACTIONS
const WALL_BOUNCE_POWER: float = 0.5
const WALL_BOUNCE_THRESHOLD: float = 400
const WALL_JUMP_PUSH_FORCE: float = 500.0

# PHYSICS
const WALL_GRAVITY: float = 1.5
const MIN_GRAVITY: float = 14.0
const MAX_GRAVITY: float = 18.0
## higher = faster transition to MAX_GRAVITY
const GRAVITY_SMOOTHING: float = 5.0
#endregion

#region VARIABLES
# MOVEMENT
var wall_contact_coyote: float = 0.0
var slide_boosts: int = 3
var is_sliding: bool = false
var slide_index: int = 0
var is_crouching: bool = false
var top_velocity_x: float = 0.0

# INPUT
var vertical_input_axis: float = 0.0  # -1.0 if down 1.0 if up
var horizontal_input_axis: float = 0.0  # -1.0 if left 1.0 if right
var is_coyote_time_activated: bool = false
var is_lurch_possible: bool = false

# PHYSICS
var previous_wall_direction: float = 0.0
var wall_direction: float = 0.0  # -1.0 if left 1.0 if right
var gravity: float = MIN_GRAVITY
## gravitational acceleration that gravity lerp to
var target_gravity: float = MIN_GRAVITY
var previous_velocity: Vector2

# VISUALS
var facing: int = 1

# STATE
var current_player_state = PlayerState.RUN

# VISUALS
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var animator: AnimationPlayer = $Animator

# TIMERS
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var lurchless_timer: Timer = $LurchlessTimer
@onready var slide_boost_cooldown_timer: Timer = $SlideBoostCooldownTimer
@onready var perfect_wall_jump_timer: Timer = $PerfectWallJumpTimer
@onready var on_wall_timer: Timer = $OnWallTimer

# RAYCASTS
@onready var left_head_nudge_outer: RayCast2D = $RayCast/HeadNudge/LeftHeadNudgeOuter
@onready var left_head_nudge_inner: RayCast2D = $RayCast/HeadNudge/LeftHeadNudgeInner
@onready var right_head_nudge_inner: RayCast2D = $RayCast/HeadNudge/RightHeadNudgeInner
@onready var right_head_nudge_outer: RayCast2D = $RayCast/HeadNudge/RightHeadNudgeOuter
@onready var left_ledge_hop_upper: RayCast2D = $RayCast/LedgeHop/LeftLedgeHopUpper
@onready var left_ledge_hop_lower: RayCast2D = $RayCast/LedgeHop/LeftLedgeHopLower
@onready var right_ledge_hop_upper: RayCast2D = $RayCast/LedgeHop/RightLedgeHopUpper
@onready var right_ledge_hop_lower: RayCast2D = $RayCast/LedgeHop/RightLedgeHopLower
@onready var left_generic_ray: RayCast2D = $RayCast/Generic/LeftGenericRay
@onready var right_generic_ray: RayCast2D = $RayCast/Generic/RightGenericRay
@onready var approaching_wall: RayCast2D = $RayCast/Generic/ApproachingWall

#COLLIDERS
@onready var collision_box: CollisionShape2D = $CollisionBox

#COMPONENTS
@onready var entity_state: EntityState = $EntityState
#endregion


func _physics_process(delta: float) -> void:
	#print( on_wall_timer.is_stopped())
	_get_wall_direction()
	_update_approaching_wall_ray()
	previous_velocity = velocity
	vertical_input_axis = Input.get_axis("down", "up")
	horizontal_input_axis = Input.get_axis("left", "right")
	#if Input.is_action_pressed("crouch") and is_on_floor():
	#_start_slide()

	#print(is_lurch_possible)
	entity_state.update_physics_state(is_on_floor())

	match entity_state.current_state:
		EntityState.State.GROUNDED:
			_process_grounded()
		EntityState.State.AIRBORNE:
			_process_airborne(delta)
		EntityState.State.BUSY:
			print("nothing here yet")
		EntityState.State.LOCKED:
			print("nothing here yet")

	match current_player_state:
		PlayerState.IDLE:
			animator.play("player_idle")
			_handle_idle()
		PlayerState.RUN:
			animator.play("player_run")
			_handle_run()
			slide_boost_cooldown_timer.start()
		PlayerState.CROUCH:
			animator.play("player_fall_idle_low")
			_handle_crouch()
		PlayerState.SLIDE:
			animator.play("player_t_pose")
			_handle_slide(delta)
		PlayerState.AIR_MOVEMENT:
			animator.play("player_fall_idle_low")
			_handle_air_momentum()
		PlayerState.WALL_SLIDE:
			_handle_wall_slide_and_jump()

	_update_jump_buffer()
	_attempt_jump()

	if velocity.y < JUMP_ASSIST_THRESHOLD:
		_handle_head_nudge()
		_handle_ledge_boost()

	velocity.y += gravity

	move_and_slide()

	_update_facing_direction()

	_flip_sprite()

	if _should_wall_bounce():
		_change_state(PlayerState.WALL_BOUNCE)

#region MOVEMENT FUNCTIONS


## Add fine air control at a cost of speed, if no arrow keys are pressed there is no loss of speed
## This allow to have advance movement tech like 'pseudo-slide-hops and pseudo-bunny-hops'
func _handle_air_momentum() -> void:
	if _can_apply_air_lurch():
		var target_speed = horizontal_input_axis * MAX_LURCH_SPEED
		if abs(velocity.x) > abs(target_speed):
			velocity.x = move_toward(velocity.x, target_speed, LURCH_STEP)
		else:
			velocity.x = move_toward(velocity.x, target_speed, LURCH_STEP)

#FIXME: the wall kick of is not working
func _start_wall_slide() -> void:
	if on_wall_timer.is_stopped():
		print("I AM CALLED")
		on_wall_timer.start(1.5)
		perfect_wall_jump_timer.start()


func _handle_wall_slide_and_jump() -> void:

	gravity = WALL_GRAVITY

	if on_wall_timer.is_stopped():
		velocity.x = -wall_direction * 200
		target_gravity = MAX_GRAVITY
		_change_state(PlayerState.AIR_MOVEMENT)
		return

	##kick off
	if Input.is_action_just_pressed("jump"):
		on_wall_timer.stop()

		if perfect_wall_jump_timer.is_stopped():
			velocity += get_wall_jump_vector(WALL_JUMP_PUSH_FORCE)
		else:
			velocity.x = -top_velocity_x * wall_direction
			velocity.y += get_wall_jump_vector(WALL_JUMP_PUSH_FORCE).y

func _get_wall_direction() -> void:
	var current_wall_ref = wall_direction

	wall_direction = 0.0

	if left_generic_ray.is_colliding():
		wall_direction = -1.0
	elif right_generic_ray.is_colliding():
		wall_direction = 1.0

	if current_wall_ref != 0.0 and current_wall_ref != wall_direction:
		previous_wall_direction = current_wall_ref


func _handle_run() -> void:
	var target_speed = horizontal_input_axis * MAX_RUN_SPEED
	velocity.x = move_toward(velocity.x, target_speed, GROUND_ACCELERATION)


func _start_crouch() -> void:
	if is_crouching:
		return

	is_crouching = true

	_resize_collider(SLIDE_Y_OFFSET, SLIDE_Y_SCALE)


func _handle_crouch() -> void:
	var target_speed = horizontal_input_axis * MAX_CROUCH_SPEED
	velocity.x = move_toward(velocity.x, target_speed, GROUND_ACCELERATION)

	if !Input.is_action_pressed("crouch"):
		_end_crouch()


func _end_crouch() -> void:
	if !is_crouching:
		return
	is_crouching = false

	_resize_collider(SLIDE_Y_OFFSET)


func _handle_idle() -> void:
	velocity.x = move_toward(velocity.x, 0.0, FRICTION)


## Bounces the player on the x if they hit a wall with speed, staggering them.
## Makes losing velocity more fun to look at, and add complex movement tech to change directions.
func _wall_bounce_stagger() -> void:
	#TODO
	# a 0.5 second animation will play for the recovery
	# a sound will play in the left or right ear depending on the side you hit the
	if _should_wall_bounce():
		velocity.x = -previous_velocity.x * WALL_BOUNCE_POWER


func _start_slide() -> void:
	if is_sliding:
		_handle_slide_boost()
		return

	is_sliding = true

	_handle_slide_boost()

	_resize_collider(SLIDE_Y_OFFSET, SLIDE_Y_SCALE)


func _handle_slide(delta: float) -> void:
	if is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, SLIDE_FRICTION * delta)
	else:
		velocity.x = velocity.x

	if !Input.is_action_pressed("crouch"):
		_end_slide()

	if _should_slide_to_crouch():
		_start_crouch()


func _end_slide() -> void:
	if !is_sliding:
		return
	is_sliding = false

	_resize_collider(SLIDE_Y_OFFSET)


func _handle_slide_boost() -> void:
	if slide_boosts > 0:
		slide_index = slide_index % SLIDE_BOOST_POWER.size()

		velocity.x *= SLIDE_BOOST_POWER[slide_index]
		print("Boost applied: ", SLIDE_BOOST_POWER[slide_index])

		slide_boosts -= 1
		slide_index += 1
	else:
		slide_index = 0


## Increase the gravitational acceleration over time to make the fall less floaty.
func _calculate_gravity(delta: float) -> void:
	gravity = lerp(gravity, target_gravity, GRAVITY_SMOOTHING * delta)


func _update_jump_buffer() -> void:
	if Input.is_action_just_pressed("jump"):
		if jump_buffer_timer.is_stopped():
			jump_buffer_timer.start()


func _attempt_jump() -> void:
	if _can_jump():
		velocity.y = JUMP_HEIGHT
		if is_sliding:
			velocity.y *= JUMP_SLIDE_MULTIPLIER
		jump_buffer_timer.stop()
		coyote_timer.stop()
		is_coyote_time_activated = true


## Cuts the jump when space is released, add more control to the jump.
func _handle_jump_cut() -> void:
	if velocity.y < 0 and (Input.is_action_just_released("jump") or is_on_ceiling()):
		velocity.y *= JUMP_CUT_POWER


## Gives a nudge when one of the top corner hit a celling so the jump doesn't feel sticky.
func _handle_head_nudge() -> void:
	if _should_nudge_left():
		velocity.x += HEAD_NUDGE_POWER
	if _should_nudge_right():
		velocity.x -= HEAD_NUDGE_POWER


## Gives a boost when the jump barely not high enough to clear a ledge so the jump is less annoying.
func _handle_ledge_boost() -> void:
	if !_can_apply_ledge_boost():
		return

	if _should_boost_left_ledge():
		velocity.y -= LEDGE_BOOST_POWER
	if _should_boost_right_ledge():
		velocity.y -= LEDGE_BOOST_POWER


#endregion

#region UTILS

func _update_approaching_wall_ray() -> void:
	var dir: float = sign(approaching_wall.target_position.x)

	if velocity.x != 0.0:
		dir = sign(velocity.x)

	var length: float = max(abs(velocity.x) / 10.0, 20.0)
	approaching_wall.target_position.x = length * dir


func get_wall_jump_vector(jump_power: float) -> Vector2:
	# Map input (-1 -> 1) to angle (0° -> 90°)
	var angle_deg = lerp(0.0, 75.0, (vertical_input_axis + 1.0) * 0.5)
	var angle_rad = deg_to_rad(angle_deg)

	var dir := Vector2(cos(angle_rad) * -wall_direction, -sin(angle_rad))

	return dir * jump_power


func _resize_collider(offset: float = 0.0, size: float = 1.0) -> void:
	var is_reset_mode = false
	if size == 1.0:
		is_reset_mode = true

	if is_reset_mode:
		collision_box.scale.y = 1.0
		left_head_nudge_outer.position.y -= offset
		left_head_nudge_inner.position.y -= offset
		right_head_nudge_outer.position.y -= offset
		right_head_nudge_inner.position.y -= offset
		collision_box.position.y -= offset
		is_reset_mode = false
	else:
		collision_box.scale.y = size
		left_head_nudge_outer.position.y += offset
		left_head_nudge_inner.position.y += offset
		right_head_nudge_outer.position.y += offset
		right_head_nudge_inner.position.y += offset
		collision_box.position.y += offset


func _update_facing_direction() -> void:
	if horizontal_input_axis < 0.0:
		facing = -1
	if horizontal_input_axis > 0.0:
		facing = 1


func _flip_sprite() -> void:
	if facing == -1:
		player_sprite.flip_h = true
	else:
		player_sprite.flip_h = false


#endregion

#region HFSM FUNCTIONS


func _change_state(new_state: PlayerState) -> void:
	if current_player_state == new_state:
		return
	print(
		"Changing state from ",
		PlayerState.keys()[current_player_state],
		" to ",
		PlayerState.keys()[new_state]
	)
	current_player_state = new_state


func _process_grounded() -> void:
	if Input.is_action_pressed("crouch"):
		_start_slide()
	previous_wall_direction = 0.0
	target_gravity = MIN_GRAVITY
	is_coyote_time_activated = false
	is_lurch_possible = false
	gravity = MIN_GRAVITY

	if !is_sliding and slide_boost_cooldown_timer.is_stopped():
		slide_boosts = 3

	if Input.is_action_just_pressed("crouch"):
		_change_state(PlayerState.CROUCH)

	if is_crouching:
		_change_state(PlayerState.CROUCH)
	elif is_sliding:
		_change_state(PlayerState.SLIDE)
	elif horizontal_input_axis != 0.0:
		_change_state(PlayerState.RUN)
	else:
		_change_state(PlayerState.IDLE)


func _process_airborne(delta: float):
	_change_state(PlayerState.AIR_MOVEMENT)
	_handle_jump_cut()
	if !_should_wall_slide():
		_calculate_gravity(delta)
		target_gravity = MAX_GRAVITY


	if approaching_wall.is_colliding():
		top_velocity_x = max(top_velocity_x, abs(velocity.x))
	else:
		top_velocity_x = 0.0

	if _should_wall_slide():
		print("Wall Jump!")
		_start_wall_slide()
		_change_state(PlayerState.WALL_SLIDE)

	if coyote_timer.is_stopped() and !is_coyote_time_activated:
		coyote_timer.start()
		is_coyote_time_activated = true

	if _should_start_lurch_time():
		lurchless_timer.start()
		is_lurch_possible = true


#endregion

#region CONDITIONS


func _should_wall_slide() -> bool:
	var is_touching_wall = left_generic_ray.is_colliding() or right_generic_ray.is_colliding()

	var is_new_wall = wall_direction != previous_wall_direction

	var pushing_away: bool = (
		horizontal_input_axis != 0.0 and sign(horizontal_input_axis) != wall_direction
	)

	return is_touching_wall and is_new_wall and velocity.y > 0.0 and not pushing_away


func _can_apply_ledge_boost() -> bool:
	var is_in_velocity_window: bool = (
		velocity.y > MIN_LEDGE_BOOST_VELOCITY and velocity.y < MAX_LEDGE_BOOST_VELOCITY
	)
	var has_horizontal_momentum: float = abs(velocity.x) > 3.0
	return is_in_velocity_window and has_horizontal_momentum


func _should_boost_left_ledge() -> bool:
	return (
		left_ledge_hop_lower.is_colliding()
		and !left_ledge_hop_upper.is_colliding()
		and velocity.x < 0
	)


func _should_boost_right_ledge() -> bool:
	return (
		right_ledge_hop_lower.is_colliding()
		and !right_ledge_hop_upper.is_colliding()
		and velocity.x > 0
	)


func _should_nudge_left() -> bool:
	return left_head_nudge_outer.is_colliding() and !left_head_nudge_inner.is_colliding()


func _should_nudge_right() -> bool:
	return right_head_nudge_outer.is_colliding() and !right_head_nudge_inner.is_colliding()


func _can_jump() -> bool:
	var has_jump_buffered = !jump_buffer_timer.is_stopped()
	var is_grounded_or_in_coyote_time = !coyote_timer.is_stopped() or is_on_floor()
	return has_jump_buffered and is_grounded_or_in_coyote_time


func _should_wall_bounce() -> bool:
	var moving_fast_enough = abs(previous_velocity.x) > WALL_BOUNCE_THRESHOLD
	return moving_fast_enough and is_on_wall()


func _can_apply_air_lurch() -> bool:
	var has_horizontal_input = horizontal_input_axis != 0
	return has_horizontal_input and is_lurch_possible


func _should_start_lurch_time() -> bool:
	return lurchless_timer.is_stopped() and !is_lurch_possible


func _should_slide_to_crouch() -> bool:
	var is_inputting_horizontal: bool = (
		abs(velocity.x) <= MAX_CROUCH_SPEED and horizontal_input_axis != 0.0
	)
	return is_inputting_horizontal or abs(velocity.x) == 0.0

#endregion
