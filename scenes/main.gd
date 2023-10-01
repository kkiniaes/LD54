extends Node2D

@export var stages : Array[PackedScene]

# Called when the node enters the scene tree for the first time.
func _ready():
	var curStage = stages[0].instantiate()
	add_child.call_deferred(curStage)
	curStage.recieve_crates.call_deferred()
	curStage.new_delivery_order.call_deferred()

func _on_main_menu_button_pressed():
	pass # Replace with function body.


func _on_retry_button_pressed():
	get_tree().reload_current_scene()
