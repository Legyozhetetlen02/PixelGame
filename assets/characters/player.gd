class_name player
extends CharacterBody2D

# --- Konstantok ---
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# --- Állapot ---
var state : String = "idle"  # idle / walk / jump / attack

# --- Node hivatkozások ---
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D

# --- Támadás animációk listája ---
var attack_anims = ["attack1", "attack2", "attack3"]

# --- Gravity a Project Settings-ből ---
var gravity : float

func _ready():
	# Project Settings-ből olvassuk ki a gravitációt
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	# Signal csatlakoztatása egyszer
	animation_player.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# --- Input ---
	var direction = Input.get_axis("left", "right")  # -1 balra, +1 jobb
	var attack_pressed = Input.is_action_just_pressed("attack")

	# --- Gravitáció ---
	if not is_on_floor():
		velocity.y += gravity * delta

	# --- Ugrás ---
	if Input.is_action_just_pressed("jump") and is_on_floor() and state != "attack":
		velocity.y = JUMP_VELOCITY

	# --- Támadás ---
	if attack_pressed and state != "attack":
		var anim = attack_anims[randi() % attack_anims.size()]
		animation_player.play(anim)
		state = "attack"

	# --- Mozgás és animációk (csak ha nem támad) ---
	if state != "attack":
		# levegőben → jump
		if not is_on_floor():
			if state != "jump":
				animation_player.play("jump")
				state = "jump"
		# mozgás → walk
		elif direction != 0:
			velocity.x = direction * SPEED
			sprite.flip_h = direction < 0
			if state != "walk":
				animation_player.play("walk")
				state = "walk"
		# nincs input → idle
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if state != "idle":
				animation_player.play("idle")
				state = "idle"
	else:
		# támadás közben áll a vízszintes sebesség
		velocity.x = 0

	# --- Mozgás végrehajtása ---
	move_and_slide()

# --- Callback a támadás animáció végén ---
func _on_animation_finished(anim_name: String) -> void:
	if state == "attack" and anim_name.begins_with("attack"):
		state = "idle"
		animation_player.play("idle")
