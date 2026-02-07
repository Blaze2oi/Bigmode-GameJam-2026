extends Node

@onready var points_container = %DeliveryPoints 
@onready var goal = %Goal
@onready var timer_label = %TimerLabel
@onready var counter_label = %CounterLabel

var current_time: float
var deliveries_count: int 
var is_game_active: bool = true

# Reward per delivery
@export var money_per_delivery: int = 50

func _ready():
	GameData.is_next_boss = false
	# Configure missions based on player level
	setup_mission_difficulty()
	
	update_ui()
	goal.body_entered.connect(_on_goal_reached)
	spawn_next_goal()

func setup_mission_difficulty():
	# Level 1: 3 deliveries, 80s | Level 2: 4 deliveries, 70s | Level 3: 5 deliveries, 60s
	var difficulty_settings = {
		1: {"deliveries": 3, "time": 80.0},
		2: {"deliveries": 4, "time": 70.0},
		3: {"deliveries": 5, "time": 60.0}
	}
	
	# Get stats based on GameData level, default to Level 1 if not found
	var stats = difficulty_settings.get(GameData.player_level, difficulty_settings[1])
	
	deliveries_count = stats["deliveries"]
	current_time = stats["time"]

func _process(delta):
	if is_game_active:
		current_time -= delta
		if current_time <= 0:
			current_time = 0
			game_over(false)
		update_ui()

func update_ui():
	timer_label.text = "Time: " + str(ceil(current_time))
	counter_label.text = "Deliveries Left: " + str(deliveries_count)

func spawn_next_goal():
	if deliveries_count > 0:
		var all_markers = points_container.get_children()
		var random_marker = all_markers.pick_random()
		goal.global_position = random_marker.global_position
		goal.show()
	else:
		game_over(true)

func _on_goal_reached(body):
	if body.is_in_group("player") or body.name == "CharacterBody2D":
		goal.hide()
		deliveries_count -= 1
		
		# Give money to player
		GameData.player_money += money_per_delivery
		
		update_ui()
		
		if deliveries_count > 0:
			await get_tree().create_timer(1.0).timeout
			spawn_next_goal()
		else:
			game_over(true)

func game_over(win: bool):
	is_game_active = false
	# Wait a moment so player sees the final result
	await get_tree().create_timer(2.0).timeout
	# Go to Upgrade Scene regardless of win/loss (or change logic if needed)
	get_tree().change_scene_to_file("res://Scenes/UpgradeShop.tscn")
