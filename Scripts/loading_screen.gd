extends Control

@onready var label: Label = $Label

func _ready():
	if GameData.is_next_boss:
		label.text = "FINAL ROOM"
	else:
		label.text = "ROOM " + str(GameData.rooms_cleared + 1)

	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file(GameData.next_room_path)
