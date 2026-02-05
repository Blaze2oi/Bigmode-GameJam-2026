extends CharacterBody2D

@onready var ray = $RayCast2D
@onready var buildings = $"../Buildings" # Ensure this path matches your scene tree

@export_group("Engine Settings")
@export var engine_power = 1200
@export var braking = -1200
@export var handbrake_force = 2500  # Positive value now; we handle direction in code
@export var max_speed_reverse = 500  # Lowered slightly for better control
@export var friction = -30.0        # Negative to oppose motion
@export var drag = -0.06

@export_group("Steering & Drift")
@export var steering_angle = 20
@export var steer_speed = 5.0
@export var wheel_base = 70
@export var slip_speed = 350
@export var traction_slow = 15.0
@export var traction_fast = 2.5

@export_group("Boost Settings")
@export var boost_power = 2000.0    # Speed added when boosting
@export var max_charges = 2         # Up to 2 charges
@export var recharge_time = 5.0# Seconds to refill one charge


@onready var boost_shader = $"../CanvasLayer/ColorRect".material # Adjust path to your ColorRect
@export var boost_duration = 1.5  # The physics boost will last for 1.5 seconds
var current_charges = 2
var recharge_timer = 0.0
var is_boosting = false
var boost_timer= 0.0

var original_zoom = Vector2.ONE # Store the default zoom

var current_steer = 0.0
var steer_direction = 0.0
var acceleration = Vector2.ZERO
var fade_tween: Tween

@export var is_active = true
func _ready():
	original_zoom = $Camera2D.zoom
func _physics_process(delta: float) -> void:
	# 1. Building Transparency Logic
	if ray.is_colliding():
		fade_buildings(0.5)
	else:
		fade_buildings(1.0)
	# Recharge Logic
	if current_charges < max_charges:
		recharge_timer += delta
		if recharge_timer >= recharge_time:
			current_charges += 1
			recharge_timer = 0.0
			#print("Boost Charged! Total: ", current_charges) # Debug check
	
	if is_active:
		$Camera2D.enabled = true
		acceleration = Vector2.ZERO
		get_input(delta)
		calculate_steering(delta)
	else:
		$Camera2D.enabled = false
		$Camera2D.zoom = original_zoom
	# 2. Apply Acceleration and Friction
	velocity += acceleration * delta
	apply_friction(delta)
	
	# 3. Final Movement
	move_and_slide()

func fade_buildings(target_alpha: float):
	if buildings.modulate.a != target_alpha:
		if fade_tween:
			fade_tween.kill()
		fade_tween = create_tween()
		fade_tween.tween_property(buildings, "modulate:a", target_alpha, 0.2)

func get_input(delta):
	# Steering Input
	var turn = Input.get_axis("left", "right")
	var target_steer = turn * deg_to_rad(steering_angle)
	
	if turn == 0:
		current_steer = move_toward(current_steer, 0, steer_speed * 2.0 * delta)
	else:
		current_steer = lerp(current_steer, target_steer, steer_speed * delta)
	
	steer_direction = current_steer

	# Forward Acceleration
	if Input.is_action_pressed("up"):
		acceleration = transform.x * engine_power

	# Handbrake vs Regular Brake vs Idle
	if Input.is_action_pressed("ui_select"): # Handbrake (Space)
		if velocity.length() > 20:
			# Force pushes OPPOSITE of velocity direction to stop "Rocket Reverse"
			acceleration = -velocity.normalized() * handbrake_force
		else:
			velocity = Vector2.ZERO # Snap to stop
			acceleration = Vector2.ZERO
		traction_fast = 0.4
	elif Input.is_action_pressed("down"): # Regular Brake/Reverse
		acceleration = transform.x * braking
		traction_fast = 0.8
	else:
		traction_fast = 2.5 # Reset grip

# 1. TRIGGER: This starts the boost when you press the key
	if Input.is_action_just_pressed("boost") and current_charges > 0:
		apply_boost() # This sets is_boosting to true and resets the timer

	# 2. ACTIVE PHYSICS: This applies the force every frame while the timer is running
	if is_boosting:
		acceleration += transform.x * boost_power
		
		# Countdown the timer
		boost_timer -= delta
		if boost_timer <= 0:
			is_boosting = false

func apply_boost():
	current_charges -= 1
	is_boosting = true
	boost_timer = boost_duration 
	
	# Create a new tween for this boost instance
	var tween = create_tween()
	
	# 1. THE ZOOM (Happens immediately)
	tween.set_parallel(true) # Let zoom and shader run at the same time
	tween.tween_property($Camera2D, "zoom", original_zoom * 0.9, 0.1)
	
	# 2. THE SHADER (Start the split)
	tween.tween_property(boost_shader, "shader_parameter/offset", 3.0, 0.1)
	
	# 3. THE HOLD & FADE (Wait for the peak, then return to normal)
	tween.set_parallel(false) # Turn off parallel so the following steps happen in order
	tween.chain().tween_interval(1.0) # Hold at 3.0 offset for 1 full second
	
	# Fade both back to initial state over 0.5 seconds
	tween.set_parallel(true)
	tween.chain().tween_property(boost_shader, "shader_parameter/offset", 0.0, 0.5)
	tween.tween_property($Camera2D, "zoom", original_zoom, 0.5)
	
func apply_friction(delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
		
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force

func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	
	var new_heading = rear_wheel.direction_to(front_wheel)

	# Traction State
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	
	if Input.is_action_pressed("ui_select"):
		traction *= 0.3

	var d = new_heading.dot(velocity.normalized())

	if d > 0:
		# 1.1 multiplier helps pull the car into the turn
		velocity = lerp(velocity, new_heading * velocity.length(), 1.1 * traction * delta)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)

	# Smooth body rotation
	var target_rotation = new_heading.angle()
	rotation = lerp_angle(rotation, target_rotation, traction * 3.0 * delta)
