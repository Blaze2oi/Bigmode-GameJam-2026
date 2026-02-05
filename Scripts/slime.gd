extends CharacterBody2D

@export_group("Movement")
@export var max_speed: float = 150.0
@export var accel: float = 700.0
@export var friction: float = 180.0
@export var bounce_strength: float = 1.1

@export_group("Stats")
@export var max_health: int = 100
@export var damage_to_player: int = 10
@export var attack_cooldown: float = 1.0

# --- NODES ---
@onready var anim = $AnimatedSprite2d
@onready var health_bar: ProgressBar = $ProgressBar

var health: int = max_health
var target: Node2D
var stun_timer: float = 0.0
var attack_timer: float = 0.0
var flee_timer: float = 0.0
var is_dying: bool = false
var is_spawning: bool = true 

func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")
	
	# Init Health Bar
	health_bar.max_value = max_health
	health_bar.value = health
	
	# Start playing idle or move
	spawn()
	
func spawn() -> void:
	is_spawning = true
	
	# Disable collisions temporarily if you want (optional)
	# $CollisionShape2D.set_deferred("disabled", true)
	
	# Play death animation backwards
	anim.play_backwards("death") 
	
	# Wait for it to finish
	await anim.animation_finished
	
	# Re-enable movement and logic
	is_spawning = false
	# $CollisionShape2D.set_deferred("disabled", false)
	
	# Start normal animation
	anim.play("down")
	

func _physics_process(delta: float) -> void:
	if is_dying or is_spawning: return

	# 2. Timers
	if stun_timer > 0: stun_timer -= delta
	if attack_timer > 0: attack_timer -= delta
	if flee_timer > 0: flee_timer -= delta

	# 3. Movement Logic
	if is_instance_valid(target):
		var dir = Vector2.ZERO
		
		# CHECK: Are we fleeing or chasing?
		if flee_timer > 0:
			# Direction AWAY from player (Self - Target)
			dir = (global_position - target.global_position).normalized()
		else:
			# Direction TOWARDS player (Target - Self)
			dir = (target.global_position - global_position).normalized()
		
		velocity += dir * accel * delta
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	# 4. Clamp & Friction
	if stun_timer <= 0:
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta * 0.5)

	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	# 5. ANIMATION LOGIC (Single Sprite)
	if velocity.length() > 10:
		update_animation(velocity)

	# 6. Move & Collision
	var collision = move_and_collide(velocity * delta)
	if collision:
		_handle_collision(collision)

func update_animation(dir: Vector2) -> void:
	var angle_deg = rad_to_deg(dir.angle())
	
	# RIGHT (-45 to 45)
	if angle_deg > -45 and angle_deg <= 45:
		anim.play("side")
		anim.flip_h = false # Face Right
		
	# DOWN (45 to 135)
	elif angle_deg > 45 and angle_deg <= 135:
		anim.play("down")
		anim.flip_h = false
		
	# UP (-135 to -45)
	elif angle_deg > -135 and angle_deg <= -45:
		anim.play("up")
		anim.flip_h = false
		
	# LEFT (Everything else)
	else:
		anim.play("side")
		anim.flip_h = true # Face Left (Flip the side animation)

func _handle_collision(collision: KinematicCollision2D) -> void:
	if is_spawning: return
	var collider = collision.get_collider()
	
	if collider.is_in_group("player"):
		if stun_timer > 0 or attack_timer > 0: return
		if collider.has_method("take_damage"):
			collider.take_damage(damage_to_player)
			attack_timer = attack_cooldown
			velocity = velocity.bounce(collision.get_normal()) * 1.5
			return

	var normal = collision.get_normal()
	velocity = velocity.bounce(normal) * bounce_strength

func knockback(dir: Vector2, force: float) -> void:
	if is_dying: return
	velocity += dir.normalized() * force
	stun_timer = 0.4 

func take_damage(amount: int) -> void:
	if is_dying or is_spawning: return
	
	health -= amount
	health_bar.value = health
	
	flee_timer = 1.5
	
	# Optional: Flash red when hit
	anim.modulate = Color(10, 10, 10) # Flash White/Bright
	await get_tree().create_timer(0.05).timeout
	anim.modulate = Color(1, 1, 1)    # Reset color
	
	print("Slime Health: ", health)
	if health <= 0:
		die()

func die() -> void:
	is_dying = true
	
	# Hide UI
	health_bar.visible = false
	
	# Disable Physics
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Play Death
	anim.flip_h = false # Reset flip so death plays normally
	anim.play("death")
	
	# Wait for animation to finish then delete
	await anim.animation_finished
	queue_free()

# Backup Hitbox logic
func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_dying or is_spawning: return
	if body.is_in_group("player"):
		if stun_timer > 0 or attack_timer > 0: return
		if body.has_method("take_damage"):
			body.take_damage(damage_to_player)
			attack_timer = attack_cooldown
