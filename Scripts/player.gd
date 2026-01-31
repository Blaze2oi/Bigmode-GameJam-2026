extends CharacterBody2D

@export_group("Movement")
@export var max_speed: float = 300.0
@export var accel: float = 1000.0
@export var friction: float = 800.0 # Increased for tighter control

@export_group("Abilities")
@export var boost_force: float = 900.0
@export var boost_cooldown: float = 0.6

# --- ATTACK SETTINGS ---
@export var attack_damage: int = 10
@export var attack_knockback: float = 5 # <--- REDUCED (Was 20.0)
@export var damage_interval: float = 0.5 

@export_group("Stats")
@export var max_health: int = 100
@export var invincibility_duration: float = 0.5 

# --- NODES ---
@onready var anim = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var health_bar: ProgressBar = $CanvasLayer/ProgressBar

var health: int = max_health
var boost_timer: float = 0.0
var invincibility_timer: float = 0.0
var damage_cooldown: float = 0.0
var is_dying: bool = false

func _ready() -> void:
	health_bar.max_value = max_health
	health_bar.value = health
	anim.play("down")

func _physics_process(delta: float) -> void:
	if is_dying: return

	# 1. Timers
	if boost_timer > 0: boost_timer -= delta
	if invincibility_timer > 0: invincibility_timer -= delta
	if damage_cooldown > 0: damage_cooldown -= delta

	# 2. Movement Inputs
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()
	
	# Apply Acceleration
	velocity += dir * accel * delta

	# 3. Clamp Speed & Friction
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	# 4. Boost Ability
	if Input.is_action_just_pressed("boost") and boost_timer <= 0:
		velocity += dir * boost_force
		boost_timer = boost_cooldown

	# 5. Animation & Rotation
	update_animation(dir)
	var angle_to_mouse = (mouse_pos - global_position).angle()
	attack_area.rotation = angle_to_mouse

	# 6. Apply Force Field (Knockback enemies)
	apply_force_field()

	# 7. MOVE AND SLIDE (Fixes getting stuck on walls)
	# move_and_slide() automatically uses 'velocity' and handles delta
	move_and_slide()

# --- FORCE FIELD LOGIC ---
func apply_force_field() -> void:
	var bodies = attack_area.get_overlapping_bodies()
	
	for body in bodies:
		if body == self: continue
		
		# Gentle constant push
		if body.has_method("knockback"):
			var k_dir = body.global_position - global_position
			body.knockback(k_dir, attack_knockback)
			
		# Periodic Damage
		if damage_cooldown <= 0:
			if body.has_method("take_damage"):
				body.take_damage(attack_damage)
				damage_cooldown = damage_interval

func update_animation(dir: Vector2) -> void:
	if velocity.length() < 5: return

	var angle_deg = rad_to_deg(dir.angle())
	
	if angle_deg > -45 and angle_deg <= 45:
		anim.play("side"); anim.flip_h = false
	elif angle_deg > 45 and angle_deg <= 135:
		anim.play("down"); anim.flip_h = false
	elif angle_deg > -135 and angle_deg <= -45:
		anim.play("up"); anim.flip_h = false
	else:
		anim.play("side"); anim.flip_h = true 

func take_damage(amount: int) -> void:
	if is_dying: return
	if invincibility_timer > 0: return 
		
	health -= amount
	health_bar.value = health
	invincibility_timer = invincibility_duration
	
	print("Player HP:", health)

	modulate.a = 0.5 
	await get_tree().create_timer(invincibility_duration).timeout
	modulate.a = 1.0 
	
	if health <= 0:
		die()

func knockback(dir: Vector2, force: float) -> void:
	if is_dying: return
	velocity += dir.normalized() * force

func die() -> void:
	if is_dying: return
	is_dying = true
	$CollisionShape2D.set_deferred("disabled", true)
	anim.play("death")
	
	await anim.animation_finished
	
	if not is_inside_tree(): return
	await get_tree().create_timer(1.0).timeout
	if not is_inside_tree(): return
	get_tree().reload_current_scene()
