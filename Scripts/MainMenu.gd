extends Control

# Defines the possible starting rooms
var start_rooms = [
	"res://Scenes/dungeon_room_1.tscn",
	"res://Scenes/dungeon_room_2.tscn", 
	"res://Scenes/dungeon_room_3.tscn"
]

func _ready() -> void:
	# Connect signals via code (or you can do it via the Node tab)
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	$VBoxContainer/OptionsButton.pressed.connect(_on_options_pressed)

func _on_start_pressed() -> void:
	# 1. Reset Global Game Data (Important!)
	GameData.player_health = 100
	GameData.rooms_cleared = 0
	GameData.player_level = 1
	# Reset other stats if needed
	
	# 2. Pick a random room to start
	var first_room = start_rooms.pick_random()
	
	# 3. Change Scene
	get_tree().change_scene_to_file(first_room)

func _on_options_pressed() -> void:
	print("Options menu not implemented yet!")
	# You can hide this menu and show an OptionsControl node here

func _on_quit_pressed() -> void:
	get_tree().quit()
