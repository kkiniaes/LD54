class_name RainbowCrate extends Crate

var timer = 0.0

func _process(delta):
	timer += delta
	if timer > 1:
		timer = 0.0
	modulate = Color.from_hsv(timer,1,1)
