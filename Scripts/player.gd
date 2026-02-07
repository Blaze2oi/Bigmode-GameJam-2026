extends CharacterBody2D

signal died 

@export_group("Movement")
@export var max_speed: float = 300.0
@export var accel: float = 1000.0
@export var friction: float = 200.0
@export var bounce_strength: float = 0.8

@export_group("Abilities")
@export var attack_damage: int = 20
@export var attack_knockback: float = 900.0
@export var attack_cooldown: float = 0.5

@export_group("Stats")
@export var max_health: int = 100

# --- NODES ---
@onready var anim = $playeranim
@onready var attack_area: Area2D = $AttackArea

# Reference to the UI Bar inside the CanvasLayer
@onready var health_bar: ProgressBar = $CanvasLayer/ProgressBar

var health: int = max_health
var attack_timer: float = 0.0
var boost_timer: float = 0.0
var is_dead: bool = false

func _ready() -> void:
	# Initialize the UI
	health_bar.max_value = max_health
	health_bar.value = health

func _physics_process(delta: float) -> void:
	
	if is_dead:
		return
	# ... (Keep existing physics logic) ...
	if boost_timer > 0: boost_timer -= delta
	if attack_timer > 0: attack_timer -= delta
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()
	velocity += dir * accel * delta
	if velocity.length() > max_speed: velocity = velocity.normalized() * max_speed
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	update_animation(dir)
	var angle_to_mouse = (mouse_pos - global_position).angle()
	attack_area.rotation = angle_to_mouse
	var collision = move_and_collide(velocity * delta)
	if collision:
		var normal = collision.get_normal()
		velocity = velocity.bounce(normal) * bounce_strength

# ... (Keep animation logic: update_animation / _activate_sprite) ...
func update_animation(dir: Vector2) -> void:
	var angle_deg = rad_to_deg(dir.angle())
	if angle_deg > -45 and angle_deg <= 45: 
		anim.flip_h = false
		anim.play("side")
	elif angle_deg > 45 and angle_deg <= 135: anim.play("down")
	elif angle_deg > -135 and angle_deg <= -45: anim.play("up")
	else: 
		anim.flip_h = true
		anim.play("side")

func _activate_sprite(active: AnimatedSprite2D) -> void:
	active.visible = true; 

func take_damage(amount: int) -> void:
	if is_dead: return
	
	health -= amount
	health_bar.value = health
	
	# Update GameData immediately so health persists between rooms 
	GameData.player_health = health 
	
	if health <= 0:
		die()

func knockback(dir: Vector2, force: float) -> void:
	velocity += dir.normalized() * force

func die() -> void:
	if is_dead: return 
	
	is_dead = true
	velocity = Vector2.ZERO 
	
	# Stop player collision so they don't get hit during the death animation
	set_collision_layer_value(1, false) 
	set_collision_mask_value(1, false)

	# Check if the animation exists in the SpriteFrames resource
	if anim.sprite_frames.has_animation("death"):
		anim.play("death")
		await anim.animation_finished
	else:
		# Fallback if you forgot to name the animation "death"
		print("Warning: 'death' animation not found in AnimatedSprite2D")
	
	# Emit the signal for DungeonRoom.gd to catch
	died.emit()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body == self: return
	if attack_timer > 0: 
		return
	if body.has_method("take_damage"): 
		body.take_damage(attack_damage)
		attack_timer = attack_cooldown
	if body.has_method("knockback"):
		var k_dir = body.global_position - global_position
		body.knockback(k_dir, attack_knockback)
