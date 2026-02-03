extends CharacterBody2D

@export_group("Movement")
@export var max_speed: float = 150.0
@export var accel: float = 800.0
@export var friction: float = 150.0
@export var bounce_strength: float = 0.85

@export_group("Stats")
@export var max_health: int = 400
@export var damage_to_player: int = 10

# Get reference to the bar
@onready var health_bar: ProgressBar = $ProgressBar

var health: int = max_health
var target: Node2D
var stun_timer: float = 0.0

func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")
	
	# Initialize bar
	health_bar.max_value = max_health
	health_bar.value = health

func _physics_process(delta: float) -> void:
	# ... (Keep existing movement logic) ...
	# This part of your code does not change, just hiding it for brevity
	if stun_timer > 0: stun_timer -= delta
	if is_instance_valid(target):
		var dir = (target.global_position - global_position).normalized()
		velocity += dir * accel * delta
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	if stun_timer <= 0: velocity = velocity.normalized() * max_speed
	else: velocity = velocity.move_toward(Vector2.ZERO, friction * delta * 0.5)
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	if velocity.length() > 5.0: rotation = velocity.angle()
	var collision = move_and_collide(velocity * delta)
	if collision: _handle_collision(collision)

func _handle_collision(collision: KinematicCollision2D) -> void:
	# ... (Keep existing collision logic) ...
	var collider = collision.get_collider()
	if collider.is_in_group("player"):
		if stun_timer > 0: return
		if collider.has_method("take_damage"):
			collider.take_damage(damage_to_player)
			velocity = velocity.bounce(collision.get_normal()) * 1.5
			return
	var normal = collision.get_normal()
	velocity = velocity.bounce(normal) * bounce_strength

func knockback(dir: Vector2, force: float) -> void:
	velocity += dir.normalized() * force
	stun_timer = 0.4 

func take_damage(amount: int) -> void:
	health -= amount
	
	# UPDATE THE BAR VISUALLY
	health_bar.value = health
	
	print("Enemy Health: ", health)
	if health <= 0:
		die()

func die() -> void:
	queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if stun_timer > 0: return
		if body.has_method("take_damage"):
			body.take_damage(damage_to_player)
