extends CharacterBody2D

@export var max_speed := 150.0
@export var accel := 800.0
@export var friction := 150.0
@export var bounce_strength := 0.85

@export var max_health := 400
var health := 400


var target : Node2D

func _ready():
	target = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if target:
		var dir = (target.global_position - global_position).normalized()
		velocity += dir * accel * delta

	# Clamp speed
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	# Friction
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	# Rotate toward movement
	if velocity.length() > 5:
		rotation = velocity.angle()

	var collision = move_and_collide(velocity * delta)
	if collision:
		bounce(collision)

func bounce(collision):
	var normal = collision.get_normal()
	velocity = velocity.bounce(normal) * bounce_strength


func knockback(dir: Vector2, force: float):
	velocity += dir.normalized() * force

func take_damage(amount):
	health -= amount
	print(health)
	if health <= 0:
		die()

func die():
	queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if not body.is_attacking:
			body.take_damage(10)
			
