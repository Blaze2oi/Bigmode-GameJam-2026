extends Node2D

@export var player_spawn: Marker2D
@export var enemy_spawn: Marker2D
@export var is_boss_room: bool = false

const LAYER_1 = preload("res://Assets/Audio/Cave Bg.mp3")
const LAYER_2 = preload("res://Assets/Audio/Cave water bg.mp3") 
const LAYER_3 = preload("res://Assets/Audio/game music.mp3")

var enemy_queue: Array = [] 

func _ready() -> void:
	# 1. Audio Setup
	AudioManager.play_dungeon_ambiance(LAYER_1, LAYER_2, LAYER_3, -20.0, -30.0, -15.0)
	
	# 2. Spawn Player
	var player = preload("res://Scenes/player.tscn").instantiate()
	player.name = "player" 
	player.global_position = player_spawn.global_position
	
	# 3. Connect player death signal
	if player.has_signal("died"):
		player.died.connect(_on_player_died) 
	
	# 4. IMPORTANT: Let the player script handle stats in its own _ready(), 
	# or assign them here using the corrected GameData names:
	# player.health = GameData.player_current_health
	# player.max_health = GameData.player_max_health
	
	add_child(player)
	
	# 5. Room Setup
	setup_wave()
	spawn_next_enemy()

func setup_wave() -> void:
	# 2. Difficulty presets based on selected Delivery Level
	# Each level now has multiple random options
	var presets = {
		1: [ # Level 1 Options
			[preload("res://Scenes/Slime.tscn"), preload("res://Scenes/Slime.tscn")],
			[preload("res://Scenes/Slime.tscn"), preload("res://Scenes/Wolf.tscn")],
			[preload("res://Scenes/Slime.tscn")], [preload("res://Scenes/BeeSwarm.tscn")]
		],
		2: [ # Level 2 Options
			[preload("res://Scenes/Wolf.tscn"), preload("res://Scenes/Wolf.tscn")],
			[preload("res://Scenes/Wolf.tscn"), preload("res://Scenes/Goblin.tscn")],
			[preload("res://Scenes/Wolf.tscn"), preload("res://Scenes/BeeSwarm.tscn")],
			[preload("res://Scenes/Slime.tscn"), preload("res://Scenes/Goblin.tscn")]
		],
		3: [ # Level 3 Options
			[preload("res://Scenes/Goblin.tscn"), preload("res://Scenes/Goblin.tscn")],
			[preload("res://Scenes/Wolf.tscn"), preload("res://Scenes/BeeSwarm.tscn"), preload("res://Scenes/Goblin.tscn")],
			[preload("res://Scenes/Goblin.tscn"), preload("res://Scenes/BeeSwarm.tscn"), preload("res://Scenes/BeeSwarm.tscn")]
		]
	}
	
	if is_boss_room:
		if GameData.player_level==1: enemy_queue = [preload("res://Scenes/Goblin.tscn")]
		if GameData.player_level==2: enemy_queue = [preload("res://Scenes/Goblin.tscn"),preload("res://Scenes/Goblin.tscn")]
		if GameData.player_level==3: enemy_queue = [preload("res://Scenes/Grim.tscn")] 
	else:
		# Pick the list based on level, then pick one random preset from that list
		var difficulty_options = presets.get(GameData.player_level, presets[1])
		enemy_queue = difficulty_options.pick_random().duplicate()

func _on_player_died() -> void:
	# 1. Handle Delivery Failed logic
	GameData.loading_text_override = "DELIVERY FAILED"
	GameData.next_room_path = "res://Scenes/delivery_selection.tscn"
	get_tree().change_scene_to_file("res://Scenes/LoadingScreen.tscn")

func spawn_next_enemy() -> void:
	if enemy_queue.is_empty():
		room_complete() 
		return
	var enemy_scene = enemy_queue.pop_front() 
	var enemy = enemy_scene.instantiate() 
	enemy.global_position = enemy_spawn.global_position 
	enemy.tree_exited.connect(_on_enemy_killed) 
	call_deferred("add_child", enemy) 

func _on_enemy_killed() -> void:
	if not is_inside_tree(): return 
	await get_tree().create_timer(1.0).timeout 
	spawn_next_enemy() 

func room_complete() -> void:
	GameData.rooms_cleared += 1 
	var p = get_node("player") 
	if p: GameData.player_current_health = p.health 
	load_next_room() 

func load_next_room() -> void:
	# 3. Boss Win -> Traveling back to future -> City Scene
	if is_boss_room:
		GameData.loading_text_override = "TRAVELLING BACK TO THE FUTURE"
		GameData.next_room_path = "res://Scenes/city.tscn"
		get_tree().change_scene_to_file("res://Scenes/LoadingScreen.tscn")
		return

	if GameData.rooms_cleared == 2 && GameData.player_level == 1:
		GameData.next_room_path = "res://Scenes/dungeon_boss_room_1.tscn"
		GameData.is_next_boss = true
	elif GameData.rooms_cleared == 3 && GameData.player_level == 2:
		GameData.next_room_path = "res://Scenes/dungeon_boss_room_1.tscn"
		GameData.is_next_boss = true
	elif GameData.rooms_cleared == 4 && GameData.player_level == 3:
		GameData.next_room_path = "res://Scenes/dungeon_boss_room_1.tscn"
		GameData.is_next_boss = true
	else:
		var rooms = ["res://Scenes/dungeon_room_1.tscn", "res://Scenes/dungeon_room_2.tscn","res://Scenes/dungeon_room_3.tscn"]
		GameData.next_room_path = rooms.pick_random()
		GameData.is_next_boss = false
	
	get_tree().change_scene_to_file("res://Scenes/LoadingScreen.tscn")
