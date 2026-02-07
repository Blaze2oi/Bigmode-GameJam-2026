extends Node

# Use Unique Names (%) to find nodes easily
@onready var points_container = %DeliveryPoints 
@onready var goal = %Goal

# --- NEW UI REFERENCES ---
@onready var timer_label = %TimerLabel
@onready var counter_label = %CounterLabel

# --- CONFIGURATION ---
@export var endless_mode: bool = false # Toggle this in the Inspector
@export var time_limit: float = 60.0  
@export var total_deliveries: int = 5 

var current_time: float
var deliveries_count: int # Changed name for clarity
var is_game_active: bool = true

func _ready():
	# Initialize values
	if endless_mode:
		current_time = 0
	else:
		current_time = time_limit
	# If endless, start at 0 and count up. If timed, start at total and count down.
	deliveries_count = 0 if endless_mode else total_deliveries
	
	update_ui()
	
	# Connect the goal's signal to this manager
	goal.body_entered.connect(_on_goal_reached)
	
	# Start the first mission
	spawn_next_goal()

func _process(delta):
	if is_game_active:
		# Only run the countdown timer if NOT in endless mode
		if not endless_mode:
			current_time -= delta
			if current_time <= 0:
				current_time = 0
				game_over(false)
		else:
			# Optional: Count UP the timer to show how long they've played
			current_time += delta
		
		update_ui()

func update_ui():
	if endless_mode:
		timer_label.text = "Playtime: " + str(ceil(current_time))
		counter_label.text = "Deliveries: " + str(deliveries_count)
	else:
		timer_label.text = "Time: " + str(ceil(current_time))
		counter_label.text = "Deliveries Left: " + str(deliveries_count)

func spawn_next_goal():
	# Always spawn a goal if in Endless, otherwise check if deliveries remain
	if endless_mode or deliveries_count > 0:
		var all_markers = points_container.get_children()
		if all_markers.size() > 0:
			var random_marker = all_markers.pick_random()
			goal.global_position = random_marker.global_position
			goal.show()
	else:
		game_over(true)

func _on_goal_reached(body):
	if body.is_in_group("player") or body.name == "CharacterBody2D":
		print("Mission Manager: Delivery Successful!")
		goal.hide()
		
		# Logic branch for scoring
		if endless_mode:
			deliveries_count += 1
		else:
			deliveries_count -= 1
		
		update_ui()
		
		# In endless, there is no "Game Over" win state, just keep spawning
		if endless_mode or deliveries_count > 0:
			await get_tree().create_timer(1.5).timeout
			spawn_next_goal()
		else:
			game_over(true)

func game_over(win: bool):
	is_game_active = false
	if win:
		print("You Win! All deliveries completed.")
	else:
		print("Game Over! Time ran out.")
