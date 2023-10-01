class_name TimedEvent extends Sprite2D

var curFrame = 0
var animTimer = 0.0
var movesTillEvent: int

signal event

func initialize(movesTillEvent: int):
	self.movesTillEvent = movesTillEvent
	GameManager.playerMoved.connect(handlePlayerMoved)
	handlePlayerMoved()
	GameManager.add_timed_event(self)

func handlePlayerMoved():
	movesTillEvent -= 1
	if movesTillEvent < 0:
		event.emit()
		GameManager.playerMoved.disconnect(handlePlayerMoved)
		GameManager.remove_timed_event(global_position)
		self.queue_free()
	else:
		$Label.text = str(movesTillEvent)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	animTimer += delta
	if curFrame == 8:
		if animTimer > movesTillEvent/20.0:
			animTimer = 0
			curFrame = 0
	else:	
		if animTimer > 0.1:
			animTimer = 0
			curFrame += 1

	frame = curFrame
