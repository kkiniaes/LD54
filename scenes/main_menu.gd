extends Control

func _ready():
	if OS.get_name() == "Web":
		$MainButtons/Quit.visible = false

func _on_back_to_main_menu_pressed():
	$MainButtons.visible = true
	$HelpMenu.visible = false

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_help_pressed():
	$MainButtons.visible = false
	$HelpMenu.visible = true

func _on_quit_pressed():
	get_tree().quit()
