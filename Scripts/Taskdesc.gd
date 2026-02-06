extends Sprite2D

@onready var label: Label = $Label
@onready var img: Sprite2D = $"11"

func _ready() -> void:
	img.visible = false

func _on_easy_task_mouse_entered() -> void:
	img.visible = true
	label.text = "A Relatively easy task to retrive a Jeweled Goblet"


func _on_easy_task_mouse_exited() -> void:
	img.visible = false
	label.text = ""


func _on_medium_task_mouse_entered() -> void:
	img.visible = true
	label.text = "A Moderately difficult task to retrive a Whispering Ring"


func _on_medium_task_mouse_exited() -> void:
	img.visible = false
	label.text = ""


func _on_hard_task_mouse_entered() -> void:
	img.visible = true
	label.text = "A difficult task to retrive a Enchanted Amulet"


func _on_hard_task_mouse_exited() -> void:
	img.visible = false
	label.text = ""
