extends Sprite2D

@onready var forks = $"forks"
@onready var camera: Camera2D = $Camera2D

enum { LEFT, RIGHT, UP, DOWN }
var facing = DOWN
var isMoving = false
var areForksExtended = false
var carrying = null
var holdDelay = 0.1

const moveSpeed = 7
const forksMinScale = 0.1
const cameraOffsetAmount = 0

func _ready():
	forks.scale.y = forksMinScale
	camera.offset = Vector2.DOWN * cameraOffsetAmount
	GameManager.player = self

func _process(delta):
	if holdDelay > 0:
		holdDelay -= delta
	else:
		if (Input.is_action_pressed("ui_down")):
			holdDelay = 1.0/(moveSpeed)
			handleInput(Vector2.DOWN)
		elif (Input.is_action_pressed("ui_up")):
			holdDelay = 1.0/(moveSpeed)
			handleInput(Vector2.UP)
		elif (Input.is_action_pressed("ui_left")):
			holdDelay = 1.0/(moveSpeed)
			handleInput(Vector2.LEFT)
		elif (Input.is_action_pressed("ui_right")):
			holdDelay = 1.0/(moveSpeed)
			handleInput(Vector2.RIGHT)
		else:
			holdDelay = 0
	if (Input.is_action_just_pressed("fork-extend")):
		handleInput("extend")
	if (Input.is_action_just_pressed("fork-up")):
		handleInput(1)
	if (Input.is_action_just_pressed("fork-down")):
		handleInput(-1)
	
	match facing:
		UP:
			camera.offset = camera.offset.lerp(Vector2.UP * cameraOffsetAmount, delta * 2)
		DOWN:
			camera.offset = camera.offset.lerp(Vector2.DOWN * cameraOffsetAmount, delta * 2)
		LEFT:
			camera.offset = camera.offset.lerp(Vector2.LEFT * cameraOffsetAmount, delta * 2)
		RIGHT:
			camera.offset = camera.offset.lerp(Vector2.RIGHT * cameraOffsetAmount, delta * 2)

func move_player(direction: Vector2):
	if isMoving:
		return
	isMoving = true
	var timer = 0.0
	var nextPos = position + direction * GameManager.GRID_SIZE
	var playerCanMove = GameManager.check_position(nextPos) == null
	var carryCanMove = (carrying == null || GameManager.check_position(get_forks_position() + direction*GameManager.GRID_SIZE) == null)
	if playerCanMove && carryCanMove:
		var startPos = position
		while (timer < 1):
			timer += get_process_delta_time() * moveSpeed
			position = startPos.lerp(nextPos, timer)
			await get_tree().process_frame
		GameManager.playerMoved.emit()
	else:
		var startPos = position + direction * GameManager.GRID_SIZE / 4.0
		nextPos = position
		while (timer < 1):
			timer += get_process_delta_time() * moveSpeed / 2.0
			position = startPos.lerp(nextPos, wiggle(timer))
			await get_tree().process_frame
	position = nextPos
	isMoving = false

func rot_player(angle):
	if isMoving:
		return
	isMoving = true
	var timer = 0.0
	if can_fork_rotate(angle):
		var startAngle = rotation
		while (timer < 1):
			timer += get_process_delta_time() * moveSpeed
			rotation = lerp_angle(startAngle, deg_to_rad(angle), ease(timer,-3))
			await get_tree().process_frame
		rotation_degrees = angle
		match angle:
			0:
				facing = DOWN
			180:
				facing = UP
			90:
				facing = LEFT
			-90:
				facing = RIGHT
	else:
		var startAngle = lerp_angle(rotation, deg_to_rad(angle), 0.5)
		var endAngle = rotation
		while (timer < 1):
			timer += get_process_delta_time() * moveSpeed
			rotation = lerp_angle(startAngle, endAngle, wiggle(timer))
			await get_tree().process_frame
		rotation = endAngle
	isMoving = false

func toggleForks(extend):
	if isMoving:
		return
	if GameManager.is_button(get_forks_position()):
		return
	isMoving = true
	var timer = 0.0
	while timer < 1:
		timer += get_process_delta_time() * moveSpeed
		if extend:
			forks.scale.y = lerpf(forksMinScale, 1.5, ease(timer, 0.2))
		else:
			forks.scale.y = lerpf(1.5, forksMinScale, ease(timer, 0.2))
		await get_tree().process_frame
	areForksExtended = extend
	isMoving = false
	if extend:
		var check = GameManager.check_position(get_forks_position())
		if check is Crate:
			carrying = check
			check.reparent(self)
			GameManager.remove_object(get_forks_position())
		else:
			toggleForks(false)
	elif carrying != null:
		carrying.reparent(get_parent())
		GameManager.add_object(carrying)
		carrying = null

func handleInput(nextInput):
	if nextInput == null:
		return
	if nextInput is Vector2:
		match nextInput:
			Vector2.UP:
				if (facing == DOWN || facing == UP):
					move_player(nextInput)
				else:
					rot_player(180)
			Vector2.DOWN:
				if (facing == DOWN || facing == UP):
					move_player(nextInput)
				else:
					rot_player(0)
			Vector2.LEFT:
				if (facing == LEFT || facing == RIGHT):
					move_player(nextInput)
				else:
					rot_player(90)
			Vector2.RIGHT:
				if (facing == LEFT || facing == RIGHT):
					move_player(nextInput)
				else:
					rot_player(-90)
	elif nextInput is int:
		pass
	else:
		toggleForks(!areForksExtended)

func get_forks_position() -> Vector2:
	var pos = position
	match facing:
		UP:
			pos += Vector2.UP * GameManager.GRID_SIZE
		DOWN:
			pos += Vector2.DOWN * GameManager.GRID_SIZE
		LEFT:
			pos += Vector2.LEFT * GameManager.GRID_SIZE
		RIGHT:
			pos += Vector2.RIGHT * GameManager.GRID_SIZE
	return pos

func can_fork_rotate(rotation) -> bool:
	if carrying == null:
		return true
		
	var pos = position
	var extraPos
	match rotation:
		0:
			pos += Vector2.DOWN * GameManager.GRID_SIZE
		180:
			pos += Vector2.UP * GameManager.GRID_SIZE
		90:
			pos += Vector2.LEFT * GameManager.GRID_SIZE
		-90:
			pos += Vector2.RIGHT * GameManager.GRID_SIZE
	
	match facing:
		UP:
			extraPos = pos + Vector2.UP * GameManager.GRID_SIZE
		DOWN:
			extraPos = pos + Vector2.DOWN * GameManager.GRID_SIZE
		LEFT:
			extraPos = pos + Vector2.LEFT * GameManager.GRID_SIZE
		RIGHT:
			extraPos = pos + Vector2.RIGHT * GameManager.GRID_SIZE
	
	return GameManager.check_position(pos) == null && GameManager.check_position(extraPos) == null
	
func wiggle(t:float) -> float:
	return sin(-13.0 * PI/2.0 * (t+1)) * pow(2, -10 * t) + 1
	
	
	
