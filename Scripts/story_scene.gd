extends Control
@onready var rich_text_label: RichTextLabel = $RichTextLabel


func _ready():
	rich_text_label.text = "The delivery must reach the heart of the cave..."
	await get_tree().create_timer(4.0).timeout
	GameData.next_room_path = "res://Scenes/dungeon_room_1.tscn"
	get_tree().change_scene_to_file("res://Scenes/LoadingScreen.tscn")
