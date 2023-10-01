extends Node

var objects = { }
var timedEvents = { }
var curTileMap : TileMap
var sendButton : Marker2D
var clearButton : Marker2D
var numBlankCrates : int
var player : Node2D

const GRID_SIZE = 100.0

signal sendPressed
signal clearPressed
signal playerMoved

func add_timed_event(object: TimedEvent):
	timedEvents[convert_position(object.global_position)] = object

func remove_timed_event(position: Vector2):
	timedEvents.erase(convert_position(position))

func check_timed_event(position: Vector2) -> bool:
	return timedEvents.has(convert_position(position))

func add_send_button(object: Marker2D):
	sendButton = object
	add_object(object)

func add_clear_button(object: Marker2D):
	clearButton = object
	add_object(object)

func is_button(position: Vector2):
	var check = check_position(position)
	if check == sendButton:
		sendPressed.emit()
		return true
	elif check == clearButton:
		clearPressed.emit()
		return true
	return false

func add_object(object: Node2D):
	objects[convert_position(object.global_position)] = object

func check_position(position: Vector2):
	var obj = objects.get(convert_position(position))
	if obj != null:
		return obj
	var tile = curTileMap.get_cell_source_id(0,curTileMap.local_to_map(curTileMap.to_local(position)))
	if tile == -1:
		return null
	else:
		return curTileMap

func remove_object(position: Vector2):
	objects.erase(convert_position(position))

func convert_position(position: Vector2) -> Vector2:
	return Vector2(round(position.x/GRID_SIZE),round(position.y/GRID_SIZE))

func _process(delta):
	if Input.is_physical_key_pressed(KEY_F5):
		get_tree().quit()
