extends Node2D

@export var player_spawn: Marker2D
@export var enemy_spawn: Marker2D
@export var is_boss_room: bool = false

# Current wave configuration
var enemy_queue: Array = []
var current_enemy_count: int = 0

func _ready() -> void:
	# 1. Spawn Player at Marker
	var player = preload("res://Scenes/player.tscn").instantiate()
	player.name = "player"
	player.global_position = player_spawn.global_position
	
	# Load global stats into player
	player.health = GameData.player_health
	# (Assign other stats here if your player script supports them)
	
	add_child(player)
	
	# 2. Setup Enemy Wave based on Level
	setup_wave()
	spawn_next_enemy()

func setup_wave() -> void:
	# Example presets (You can move this to a separate Resource file later)
	var presets = {
		1: [preload("res://Scenes/Slime.tscn"), preload("res://Scenes/Wolf.tscn")],
		2: [preload("res://Scenes/Wolf.tscn"), preload("res://Scenes/Wolf.tscn")],
		# Default fallback
		"default": [preload("res://Scenes/Slime.tscn")]
	}
	
	var level = GameData.player_level
	if is_boss_room:
		# Special boss wave
		enemy_queue = [preload("res://Scenes/Goblin.tscn")]
	elif presets.has(level):
		enemy_queue = presets[level].duplicate()
	else:
		enemy_queue = presets["default"].duplicate()

func spawn_next_enemy() -> void:
	if enemy_queue.is_empty():
		room_complete()
		return
		
	var enemy_scene = enemy_queue.pop_front()
	var enemy = enemy_scene.instantiate()
	enemy.global_position = enemy_spawn.global_position
	
	# Connect the "tree_exited" signal (triggered when queue_free() is called)
	# NOTE: It's better to add a custom signal "died" to your enemies, 
	# but tree_exited works if they queue_free() on death.
	enemy.tree_exited.connect(_on_enemy_killed)
	
	call_deferred("add_child", enemy)
	
	# Optional: Trigger spawn animation here if you have one

func _on_enemy_killed() -> void:
	if not is_inside_tree(): return
	# Wait a moment before spawning next one?
	await get_tree().create_timer(1.0).timeout
	spawn_next_enemy()

func room_complete() -> void:
	print("Room Cleared!")
	GameData.rooms_cleared += 1
	
	# Save current stats back to Global before leaving
	var p = get_node("player") # Ensure your player node is named "Player"
	if p:
		GameData.player_health = p.health
	
	# Decide Next Room
	load_next_room()

func load_next_room() -> void:
	# Logic to pick the next room
	# If we just finished room 1, go to 2, etc.
	# You can randomize this in a Main Menu script, but here is a simple sequence:
	
	if is_boss_room:
		print("YOU WIN THE GAME")
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	elif GameData.rooms_cleared >= 2:
		get_tree().change_scene_to_file("res://Scenes/dungeon_boss_room_1.tscn")
	else:
		# Randomly pick a normal room, or follow a list
		# For this example, let's just reload random normal rooms
		var rooms = ["res://Scenes/dungeon_room_1.tscn", "res://Scenes/dungeon_room_2.tscn", "res://Scenes/dungeon_room_3.tscn"]
		var next_room = rooms.pick_random()
		get_tree().change_scene_to_file(next_room)
