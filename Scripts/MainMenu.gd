extends Control

# Defines the possible starting rooms

func _ready() -> void:
	# Connect signals via code (or you can do it via the Node tab)
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_start_pressed() -> void:
	
	GameData.player_health = 100 
	GameData.rooms_cleared = 0 
	get_tree().change_scene_to_file("res://Scenes/delivery_selection.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
