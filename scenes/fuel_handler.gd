extends Panel

var fuel
var animTimer = 0.0
var score = 0
var numRefuels = 0

const MAX_FUEL = 200

func _ready():
	GameManager.playerMoved.connect(handle_player_move)
	GameManager.refuelEvent.connect(handle_refuel_event)
	GameManager.cratesDelivered.connect(handle_crates_delivered)
	fuel = MAX_FUEL
	$ProgressBar.max_value = MAX_FUEL
	%ScoreLabel.text = str(score)

func handle_crates_delivered(numCrates):
	score += numCrates
	%ScoreLabel.text = str(score)
	var timer = 0.0
	while (timer < 1.0):
		timer += get_process_delta_time() / 2
		%ScoreBG.scale = Vector2.ONE * lerpf(1.5,1.0,GameManager.wiggle(timer))
		await get_tree().process_frame

func _process(delta):
	if fuel < MAX_FUEL / 3.0:
		$ProgressBar.modulate = Color.RED
	if fuel < MAX_FUEL / 4.0:
		animTimer += delta * 10.0
		scale = Vector2.ONE * lerpf(0.9,1.2,inverse_lerp(-1,1,sin(animTimer)))

func handle_player_move():
	fuel -= 1
	$ProgressBar.value = fuel
	if(fuel < 0):
		GameManager.gameOver.emit()
		%GameOverPanel.visible = true
		%GameOverPanel/Details.text = str(score) + "\n" + str(numRefuels)

func handle_refuel_event():
	fuel = MAX_FUEL
	numRefuels += 1
	animTimer = 0
	scale = Vector2.ONE
	$ProgressBar.modulate = Color.WHITE
	$ProgressBar.value = fuel
