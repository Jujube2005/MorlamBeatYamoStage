extends Sprite2D

@onready var falling_key = preload("res://objects/falling_key.tscn")
@onready var score_text = preload("res://objects/score_press_text.tscn")

@export var key_name: String = ""

var falling_key_queue: Array = []

# Thresholds
var perfect_press_threshold: float = 30
var great_press_threshold: float = 50
var good_press_threshold: float = 60
var ok_press_threshold: float = 80

# Scores
var perfect_press_score: float = 250
var great_press_score: float = 100
var good_press_score: float = 50
var ok_press_score: float = 20


func _ready():
	$GlowOverlay.frame = frame + 4
	$GlowOverlay.modulate.a = 0
	
	Signals.CreateFallingKey.connect(CreateFallingKey)


func _process(delta):

	# =========================
	# HIT
	# =========================
	if Input.is_action_just_pressed(key_name):

		if falling_key_queue.is_empty():
			return

		var key_to_hit = falling_key_queue.front()
		var distance = abs(key_to_hit.pass_threshold - key_to_hit.global_position.y)

		# Animation
		PlayHitAnimation()

		var result_text := ""
		var score_to_add := 0
		var is_combo := false

		if distance < perfect_press_threshold:
			result_text = "PERFECT"
			score_to_add = perfect_press_score
			is_combo = true

		elif distance < great_press_threshold:
			result_text = "GREAT"
			score_to_add = great_press_score
			is_combo = true

		elif distance < good_press_threshold:
			result_text = "GOOD"
			score_to_add = good_press_score
			is_combo = true

		elif distance < ok_press_threshold:
			result_text = "OK"
			score_to_add = ok_press_score
			is_combo = true

		else:
			result_text = "MISS"
			PlayMiss()
			Signals.ResetCombo.emit()

		# ถ้าไม่ใช่ MISS
		if is_combo:
			PlayHit()
			Signals.IncrementScore.emit(score_to_add)
			Signals.IncrementCombo.emit()

		# ลบโน้ตที่กด
		key_to_hit.queue_free()
		falling_key_queue.pop_front()

		ShowScoreText(result_text)


	# =========================
	# AUTO MISS (โน้ตผ่านไปแล้ว)
	# =========================
	if not falling_key_queue.is_empty():

		var front_key = falling_key_queue.front()

		if front_key != null and front_key.has_passed:
			
			ShowScoreText("MISS")
			PlayMiss()
			Signals.ResetCombo.emit()

			front_key.queue_free()
			falling_key_queue.pop_front()


# =========================
# FUNCTIONS
# =========================

func PlayHit():
	if not $HitSoundPlayer.playing:
		$HitSoundPlayer.play()

func PlayMiss():
	if not $MissSoundPlayer.playing:
		$MissSoundPlayer.play()

func PlayHitAnimation():
	$AnimationPlayer.stop()
	$GlowOverlay.modulate.a = 1
	$AnimationPlayer.play("key_hit")

func ShowScoreText(text: String):
	var st_inst = score_text.instantiate()
	get_tree().root.add_child(st_inst)
	st_inst.SetTextInfo(text)
	st_inst.global_position = global_position + Vector2(0, -20)


# =========================
# SPAWN KEY
# =========================
func CreateFallingKey(button_name: String):
	if button_name == key_name:
		var fk_inst = falling_key.instantiate()
		get_tree().root.add_child(fk_inst)

		fk_inst.Setup(position.x, frame + 4)
		falling_key_queue.append(fk_inst)


func _on_random_spawn_timer_timeout():
	$RandomSpawnTimer.wait_time = randf_range(0.4, 3.0)
	$RandomSpawnTimer.start()
