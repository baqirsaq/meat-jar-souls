extends CharacterBody2D
#TODO:
# update the resize_colider function
# refactor accel
# add a state machine
# add walljumps
# add horizontal wallrun & wallkicks
# add wall clime and stamina
# add ledge grab

# timers
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var lurchless_timer: Timer = $LurchlessTimer
@onready var slide_boost_cooldown_timer: Timer = $SlideBoostCooldownTimer

# raycasts
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

#coliders
@onready var collision_box: CollisionShape2D = $CollisionBox

var is_coyote_time_activated: bool = false
const JUMP_HEIGHT: float = -430.0
## how fast does the jump stop after it cut, makes the transition really smooth
const JUMP_CUT_POWER: float = 0.5
## only assist movement when moving upward significant 
const JUMP_ASSIST_THRESHOLD: float = JUMP_HEIGHT/2.0 
const JUMP_SLIDE_MULTIPLIER: float = 0.75
const HEAD_NUDGE_POWER: float = 1.75
const LEDGE_BOOST_POWER: float = 125
const MIN_LEDGE_BOOST_VELOCITY = -30.0
const MAX_LEDGE_BOOST_VELOCITY = -5.0
const MIN_GRAVITY: float = 12.0
const MAX_GRAVITY: float = 14.5
## higher = faster transition to MAX_GRAVITY
const GRAVITY_SMOOTHING: float = 5.0 
var gravity: float = MIN_GRAVITY
## gravitational acceleration that gravity lerp to
var target_gravity: float = MIN_GRAVITY

const MAX_RUN_SPEED: float = 350.0
const MAX_LURCH_SPEED: float = 300.0
const GROUND_ACCELERATION: float = 30.0
const LURCH_STEP: float = 50.0
const FRICTION: float = 20.0
const SLIDE_FRICTION: float = 1.0
const SLIDE_BOOST_POWER: Array = [1.75, 1.2, 1.2]
var slide_boosts: int = 3
## shrink the collision height
const SLIDE_Y_SCALE: float = 0.5
const SLIDE_Y_OFFSET: float = 8.0 
var is_sliding: bool = false
var is_lurch_time_activated: bool = false
var previous_velocity: Vector2

var horizontal_input_axis: float = 0.0
var movement_lerp_factor: float = 0.0
var slide_index: int = 0 

enum PlayerState{ON_GROUND, IN_AIR, ON_WALL} #TODO

func _physics_process(delta: float) -> void:
	
	previous_velocity = velocity
	
	# horizontal movment
	horizontal_input_axis = Input.get_axis("left", "right")
	if Input.is_action_pressed("crouch") and is_on_floor():
		start_slide()
	
	if is_on_floor():
		if !is_sliding and slide_boost_cooldown_timer.is_stopped():
			slide_boosts = 3
		
		if Input.is_action_just_pressed("crouch"):
			start_slide()
		
		if is_sliding:
			handle_slide(delta)
		else:
			# Normal ground movement
			apply_ground_movement()
			slide_boost_cooldown_timer.start()
	else:
		end_slide()
		handle_air_momentum()
	
	# vertical movment
	if is_on_floor():
		target_gravity = MIN_GRAVITY
		is_coyote_time_activated = false
		is_lurch_time_activated = false
		gravity = lerp(gravity, MIN_GRAVITY, MIN_GRAVITY * delta)
	else:
		target_gravity = MAX_GRAVITY
		if coyote_timer.is_stopped() and !is_coyote_time_activated:
			coyote_timer.start()
			is_coyote_time_activated = true
		if lurchless_timer.is_stopped() and !is_lurch_time_activated:
			lurchless_timer.start()
			is_lurch_time_activated = true
		handle_jump_cut()
		
		calculate_gravity(delta);
	
	update_jump_buffer()
	attempt_jump()
	
	
	if velocity.y < JUMP_ASSIST_THRESHOLD:
		handle_head_nudge()
		handle_ledge_boost()
	
	velocity.y += gravity
	
	move_and_slide()
	
	wall_bounce_stagger()

func handle_air_momentum() -> void:
	if horizontal_input_axis != 0 and is_lurch_time_activated:
		var target_speed = horizontal_input_axis * MAX_LURCH_SPEED
		if abs(velocity.x) > abs(target_speed):
			velocity.x = move_toward(velocity.x, target_speed, LURCH_STEP)
		else:
			velocity.x = move_toward(velocity.x, target_speed, LURCH_STEP)
	else:
		velocity.x = velocity.x

func apply_ground_movement() -> void:
	var target_speed = horizontal_input_axis * MAX_RUN_SPEED
	var accelation = GROUND_ACCELERATION
	var decelation = FRICTION
	
	var rate = accelation if horizontal_input_axis != 0 else decelation
	velocity.x = move_toward(velocity.x, target_speed, rate)

func wall_bounce_stagger() -> void: ## bounces the player on the x if they hit a wall with speed, staggering them. makes losing velocity more fun to look at atleast.
	#TODO
	# a 0.5 second animation will play for the recovery 
	# a sound will play in the left or right ear depending on the side you hit the 
	if abs(previous_velocity.x) > 400 and is_on_wall():
		print("applied")
		velocity.x = -previous_velocity.x * 0.75

func start_slide() -> void:
	if is_sliding: 
		return
	
	is_sliding = true
	
	if slide_boosts > 0:
		slide_index = slide_index % SLIDE_BOOST_POWER.size()
		
		velocity.x *= SLIDE_BOOST_POWER[slide_index]
		print("Boost applied: ", SLIDE_BOOST_POWER[slide_index])
		
		slide_boosts -= 1
		slide_index += 1
	else:
		slide_index = 0
	
	resize_collider(SLIDE_Y_OFFSET, SLIDE_Y_SCALE)

func handle_slide(delta: float) -> void:
	velocity.x = lerp(velocity.x, 0.0, SLIDE_FRICTION * delta)
	
	if !Input.is_action_pressed("crouch"):
		end_slide()

func end_slide() -> void:
	if !is_sliding: return
	is_sliding = false
	
	resize_collider(SLIDE_Y_OFFSET)

func calculate_gravity(delta: float) -> void: ## increase the gravitational acceleration over time to make the fall less floaty
	gravity = lerp(gravity, target_gravity, GRAVITY_SMOOTHING * delta)

func update_jump_buffer() -> void:
	if Input.is_action_just_pressed("jump"):
		if jump_buffer_timer.is_stopped():
			jump_buffer_timer.start()

func attempt_jump() -> void: 
	if !jump_buffer_timer.is_stopped() and (!coyote_timer.is_stopped() or is_on_floor()):
		velocity.y = JUMP_HEIGHT
		if is_sliding:
			velocity.y *= JUMP_SLIDE_MULTIPLIER
			end_slide()
		jump_buffer_timer.stop()
		coyote_timer.stop()
		is_coyote_time_activated = true

func handle_jump_cut() -> void: ## cuts the jump when space is released, add more control to the jump
	if velocity.y < 0 and (Input.is_action_just_released("jump") or is_on_ceiling()):
		velocity.y *= JUMP_CUT_POWER

func handle_head_nudge() -> void: ## gives a nudge when one of the top corner hit a celling so the jump doesn't feel sticky.
	if left_head_nudge_outer.is_colliding() and !left_head_nudge_inner.is_colliding():
		velocity.x += HEAD_NUDGE_POWER
	elif right_head_nudge_outer.is_colliding() and !right_head_nudge_inner.is_colliding():
		velocity.x -= HEAD_NUDGE_POWER

func handle_ledge_boost() -> void: ## gives a boost when the jump barely not high enough to clear a ledge so the jump is less annoying.
	var is_in_boost_window : bool = velocity.y > MIN_LEDGE_BOOST_VELOCITY and velocity.y < MAX_LEDGE_BOOST_VELOCITY
	var moving_fast_enough : bool = abs(velocity.x) > 3.0
	
	if !(is_in_boost_window and moving_fast_enough):
		return
	
	# check left
	if left_ledge_hop_lower.is_colliding() and !left_ledge_hop_upper.is_colliding() and velocity.x < 0:
		velocity.y += LEDGE_BOOST_POWER
	# check right
	if right_ledge_hop_lower.is_colliding() and !right_ledge_hop_upper.is_colliding() and velocity.x > 0:
		velocity.y += LEDGE_BOOST_POWER

func resize_collider(offset: float = 0.0, size: float = 1.0) -> void:
	var is_reset_mode = false
	if size == 1.0:
		is_reset_mode = true #TODO
	
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
