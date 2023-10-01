extends Node2D

@export var stages : Array[PackedScene]

# Called when the node enters the scene tree for the first time.
func _ready():
	var curStage = stages[0].instantiate()
	get_tree().root.add_child.call_deferred(curStage)
	curStage.recieve_crates.call_deferred()
	curStage.new_delivery_order.call_deferred()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
