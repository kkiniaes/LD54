extends Node

@export var recieveSpots: Array[Marker2D]
@export var deliverySpots: Array[Sprite2D]
@export var sendButton : Marker2D
@export var clearButton : Marker2D
@export var deliveryDoors : Node2D
@export var recievingDoors : Node2D

var doorsAnimating = false

const crateScene : PackedScene = preload("res://scenes/crate.tscn")
const trashPickupScene : PackedScene = preload("res://scenes/trash_pickup.tscn")

const colors = [Color.RED, Color.BLUE, Color.GREEN]

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.curTileMap = $TileMap
	GameManager.add_send_button(sendButton)
	GameManager.sendPressed.connect(handle_send_pressed)
	GameManager.add_clear_button(clearButton)
	GameManager.clearPressed.connect(handle_clear_pressed)
	for i in 10:
		var randX = randi_range(-6,6)
		var randY = randi_range(-3,3)
		var position = Vector2(randX,randY)*100
		if !position.is_zero_approx():
			if GameManager.check_position(position) == null:
				if i < 5:
					spawn_random_crate(position, 0)
				else:
					spawn_random_crate(position, 1)

func handle_send_pressed():
	if doorsAnimating:
		return
	var allGood = true
	for sprite in deliverySpots:
		var check = GameManager.check_position(sprite.global_position)
		if sprite.visible:
			if !(check is Crate):
				allGood = false
				break
			elif !check.modulate.is_equal_approx(sprite.modulate):
				allGood = false
				break
		elif check != null:
			allGood = false
	if allGood:
		await animateDoors(deliveryDoors, false)
		for sprite in deliverySpots:
			if sprite.visible:
				var check = GameManager.check_position(sprite.global_position)
				check.destroy()
				sprite.visible = false
		new_delivery_order()
		await animateDoors(deliveryDoors, true)
		spawn_trash_pickups()

func spawn_trash_pickups():
	var numTrashPickups = GameManager.numBlankCrates / 2 + randi_range(-4,0)
	numTrashPickups = clamp(numTrashPickups, 1, 5)
	for i in numTrashPickups:
		var randX = randi_range(-6,6)
		var randY = randi_range(-3,3)
		var position = Vector2(randX,randY)*100
		if !GameManager.check_timed_event(position):
			var newTrash = trashPickupScene.instantiate()
			get_tree().root.add_child(newTrash)
			newTrash.global_position = position
			newTrash.initialize(51)

func handle_clear_pressed():
	if doorsAnimating:
		return
	var allGood = true
	for spot in recieveSpots:
		var check = GameManager.check_position(spot.global_position)
		if check != null:
			allGood = false
			break
	
	if allGood:
		await animateDoors(recievingDoors, false)
		recieve_crates()
		animateDoors(recievingDoors, true)

func animateDoors(doorRoot, open):
	doorsAnimating = true
	var timer = 0.0
	var start_scale
	var end_scale
	
	if open:
		start_scale = 1.0
		end_scale = 0.0
	else:
		start_scale = 0.0
		end_scale = 1.0
	
	while (timer < 1.0):
		timer += get_process_delta_time()
		for door in doorRoot.get_children():
			door.scale.x = lerpf(start_scale,end_scale,ease(timer,4))
		await get_tree().process_frame
	
	for door in doorRoot.get_children():
		door.scale.x = end_scale
	
	doorsAnimating = false

func recieve_crates():
	for spot in recieveSpots:
		spawn_random_crate(spot.global_position, 0.4)

func spawn_random_crate(global_position, trashChance):
	var spawnedCrate = crateScene.instantiate()
	get_tree().root.add_child(spawnedCrate)
	spawnedCrate.global_position = global_position
	var color = null
	if randf() > trashChance:
			color = colors[randi() % colors.size()]
	spawnedCrate.initialize(color)

func new_delivery_order():
	var pickedDeliverySpots = []
	var randomDeliverCount = 3 + randi() % 4
	for i in randomDeliverCount:
		var randDeliver = randi() % recieveSpots.size()
		while randDeliver in pickedDeliverySpots:
			randDeliver = randi() % recieveSpots.size()
		pickedDeliverySpots.append(randDeliver)
		deliverySpots[randDeliver].modulate = colors[randi() % colors.size()]
	for i in deliverySpots.size():
		deliverySpots[i].visible = i in pickedDeliverySpots
