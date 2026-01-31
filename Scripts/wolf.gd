extends CharacterBody2D

@export_group("Movement")
@export var max_speed: float = 230.0
@export var accel: float = 900.0
@export var friction: float = 250.0
@export var bounce_strength: float = 0.55

@export_group("Stats")
@export var max_health: int = 250
@export var damage_to_player: int = 15
@export var push_force: float = 100.0 # Force to push wolf away after biting

# --- NODES ---
@onready var anim = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $ProgressBar

var health: int = max_health
var target: Node2D
var stun_timer: float = 0.0
var attack_cooldown: float = 0.0 # <--- NEW: Prevents instant kill
var is_dying: bool = false 

func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")
	
	health_bar.max_value = max_health
	health_bar.value = health
	anim.play("down")

func _physics_process(delta: float) -> void:
	if is_dying: return

	# --- TIMERS ---
	if stun_timer > 0: stun_timer -= delta
	if attack_cooldown > 0: attack_cooldown -= delta # <--- Count down cooldown

	# --- MOVEMENT ---
	if is_instance_valid(target):
		var dir = (target.global_position - global_position).normalized()
		velocity += dir * accel * delta
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	# --- CLAMP & FRICTION ---
	if stun_timer <= 0:
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta * 0.5)

	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	# --- ANIMATION ---
	if velocity.length() > 10:
		update_animation(velocity)

	# --- COLLISION ---
	var collision = move_and_collide(velocity * delta)
	if collision:
		_handle_collision(collision)

func update_animation(dir: Vector2) -> void:
	var angle_deg = rad_to_deg(dir.angle())
	
	if angle_deg > -45 and angle_deg <= 45:
		anim.play("side"); anim.flip_h = false 
	elif angle_deg > 45 and angle_deg <= 135:
		anim.play("down"); anim.flip_h = false
	elif angle_deg > -135 and angle_deg <= -45:
		anim.play("up"); anim.flip_h = false
	else:
		anim.play("side"); anim.flip_h = true 

func _handle_collision(collision: KinematicCollision2D) -> void:
	var collider = collision.get_collider()
	
	# 1. PLAYER HIT LOGIC
	if collider.is_in_group("player"):
		# If we are stunned OR our attack is on cooldown, do nothing
		if stun_timer > 0 or attack_cooldown > 0: 
			return
		
		# DEAL DAMAGE
		if collider.has_method("take_damage"):
			collider.take_damage(damage_to_player)
			
			# Reset Cooldown (Wait 1.0 second before biting again)
			attack_cooldown = 1.0 
			
			# FORCE SEPARATION: Push wolf away from player strongly
			var push_dir = (global_position - collider.global_position).normalized()
			velocity = push_dir * push_force
			return

	# 2. WALL BOUNCE LOGIC
	var normal = collision.get_normal()
	velocity = velocity.bounce(normal) * bounce_strength

func knockback(dir: Vector2, force: float) -> void:
	if is_dying: return
	velocity += dir.normalized() * force
	stun_timer = 0.4 

func take_damage(amount: int) -> void:
	if is_dying: return
	
	health -= amount
	health_bar.value = health
	
	anim.modulate = Color(10, 10, 10) 
	await get_tree().create_timer(0.05).timeout
	anim.modulate = Color(1, 1, 1)    
	
	print("Wolf Health: ", health)
	if health <= 0:
		die()

func die() -> void:
	is_dying = true
	health_bar.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	
	var current_anim = anim.animation
	if current_anim == "up": anim.play("death_up")
	elif current_anim == "down": anim.play("death_down")
	else: anim.play("death_side")
	
	await anim.animation_finished
	queue_free()
