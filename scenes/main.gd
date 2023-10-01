extends Node2D

@export var stages : Array[PackedScene]

var escapePressed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var curStage = stages[0].instantiate()
	add_child.call_deferred(curStage)
	curStage.recieve_crates.call_deferred()
	curStage.new_delivery_order.call_deferred()
	if OS.get_name() == "Web":
		$CanvasLayer/Pause/MainButtons/Quit.visible = false

func _process(delta):
	if escapePressed:
		if !Input.is_physical_key_pressed(KEY_ESCAPE):
			escapePressed = false
		return
	if Input.is_physical_key_pressed(KEY_ESCAPE):
		escapePressed = true
		GameManager.isPaused = !GameManager.isPaused
		$CanvasLayer/Pause.visible = GameManager.isPaused

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_retry_button_pressed():
	get_tree().reload_current_scene()

func _on_continue_pressed():
	GameManager.isPaused = false
	$CanvasLayer/Pause.visible = GameManager.isPaused

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_help_pressed():
	$CanvasLayer/Pause/HelpMenu.visible = true
	$CanvasLayer/Pause/MainButtons.visible = false

func _on_quit_pressed():
	get_tree().quit()

func _on_back_to_main_menu_pressed():
	$CanvasLayer/Pause/HelpMenu.visible = false
	$CanvasLayer/Pause/MainButtons.visible = true
