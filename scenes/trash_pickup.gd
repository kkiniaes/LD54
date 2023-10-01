extends Node2D

@onready var timedEvent: TimedEvent = $TimedEvent

func initialize(movesTillEvent: int):
	timedEvent.event.connect(handleTimedEvent)
	timedEvent.initialize(movesTillEvent)

func handleTimedEvent():
	var check = GameManager.check_position(global_position)
	if check != null && (check is Crate || check is HeavyCrate):
		check.destroy()
	self.queue_free()
