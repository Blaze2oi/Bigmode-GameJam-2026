extends Control
@onready var rich_text_label: RichTextLabel = $RichTextLabel


func _ready():
	rich_text_label.text = "The Item to be delivered in the future must be found in this slick Dungeon under the curse of eternal slipping"
	await get_tree().create_timer(5.0).timeout
	GameData.next_room_path = [("res://Scenes/dungeon_room_1.tscn"), ("res://Scenes/dungeon_room_2.tscn"), ("res://Scenes/dungeon_room_3.tscn")].pick_random()
	get_tree().change_scene_to_file("res://Scenes/LoadingScreen.tscn")
