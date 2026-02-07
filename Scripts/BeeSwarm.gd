extends Node2D

func _process(_delta):
	# If all children (bees) are dead/removed, remove the swarm container
	if get_child_count() == 0:
		queue_free()
