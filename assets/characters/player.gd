class_name player extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var state : String = "idle"
var cardial_direction : Vector2 = Vector2.DOWN

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D

func _ready():
	
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		sprite.flip_h = direction < 0
		
		if state != "walk_right":
			animation_player.play("walk_right")
			state = "walk_right"
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if state != "idle":
			animation_player.play("idle")
			state = "idle"

	move_and_slide()
