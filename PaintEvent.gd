extends Node2D

@onready var timedEvent: TimedEvent = $TimedEvent

func initialize(movesTillEvent: int, color: Color):
	timedEvent.event.connect(handleTimedEvent)
	timedEvent.initialize(movesTillEvent)
	$"Paint-icon".modulate = color

func handleTimedEvent():
	var check = GameManager.check_position(global_position)
	if check != null && check is Crate:
		check.modulate = $"Paint-icon".modulate
		if check.isBlankCrate:
			check.isBlankCrate = false
			GameManager.numBlankCrates -= 1
	self.queue_free()
