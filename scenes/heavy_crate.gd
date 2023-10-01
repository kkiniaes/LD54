class_name HeavyCrate extends Sprite2D


func initialize():
	GameManager.add_object(self)

func destroy():
	GameManager.remove_object(global_position)
	self.queue_free()
