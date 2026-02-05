extends Node

# Use Unique Names (%) to find nodes easily
@onready var points_container = %DeliveryPoints 
@onready var goal = %Goal

func _ready():
	# Connect the goal's signal to this manager
	# This assumes your Goal scene's Area2D is the root node
	goal.body_entered.connect(_on_goal_reached)
	
	# Start the first mission
	spawn_next_goal()

func spawn_next_goal():
	# 1. Get the list of all markers you placed
	var all_markers = points_container.get_children()
	
	if all_markers.size() > 0:
		# 2. Pick a random marker
		var random_marker = all_markers.pick_random()
		
		# 3. Move the Goal scene to that marker's position
		goal.global_position = random_marker.global_position
		goal.show()

func _on_goal_reached(body):
	# Check if the object entering is the Car
	if body.is_in_group("player") or body.name == "CharacterBody2D":
		print("Mission Manager: Delivery Successful!")
		goal.hide()
		
		# Wait 1.5 seconds before the next delivery appears
		await get_tree().create_timer(1.5).timeout
		spawn_next_goal()
