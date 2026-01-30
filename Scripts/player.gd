extends CharacterBody2D

@export var max_speed := 300.0
@export var accel := 1000.0
@export var friction := 200.0
@export var bounce_strength := 0.8
@export var boost_force := 900.0
@export var boost_cooldown := 0.6

@export var max_health := 100
var health := 100
var is_attacking := false


var boost_timer := 0.0

func _physics_process(delta):
	boost_timer -= delta

	# Direction toward mouse
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()

	# Accelerate toward mouse
	velocity += dir * accel * delta

	# Clamp speed
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	# Friction
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	# BOOST
	if Input.is_action_just_pressed("boost") and boost_timer <= 0:
		velocity += dir * boost_force
		boost_timer = boost_cooldown

	# Rotate toward movement direction
	if velocity.length() > 5:
		rotation = velocity.angle()

	# Move
	var collision = move_and_collide(velocity * delta)

	if collision:
		bounce(collision)
		
	if Input.is_action_just_pressed("attack"):
		is_attacking = true
		$AttackArea.monitoring = true
		await get_tree().create_timer(0.2).timeout
		is_attacking = false
		$AttackArea.monitoring = false

# ---- PUT THIS OUTSIDE _physics_process ----
func bounce(collision):
	var normal = collision.get_normal()
	velocity = velocity.bounce(normal) * bounce_strength
	
func attack():
	for body in $AttackArea.get_overlapping_bodies():
		if body.has_method("knockback"):
			var dir = body.global_position - global_position
			body.knockback(dir, 1900)
func take_damage(amount):
	health -= amount
	print("Player HP:", health)

	if health <= 0:
		die()

func die():
	print("Player Dead")
	queue_free() # later replace with restart


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(20)

	if body.has_method("knockback"):
		var dir = body.global_position - global_position
		body.knockback(dir, 900)
