class_name Crate extends Sprite2D

var isBlankCrate = false

# Called when the node enters the scene tree for the first time.
func initialize(color):
	GameManager.add_object(self)
	if color == null:
		isBlankCrate = true
		GameManager.numBlankCrates += 1
	else:
		modulate = color

func destroy():
	GameManager.remove_object(global_position)
	if isBlankCrate:
		GameManager.numBlankCrates -= 1
	self.queue_free()
