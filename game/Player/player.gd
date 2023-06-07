extends CharacterBody2D

const SPEED = 300.0
const DASH = 600.0
const JUMP_VELOCITY = -400.0
const FRICTION = 700

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var isDash = false
var CanDash = true
@onready var timer_dash = $Timer
@onready var animated_sprite = $AnimatedSprite2D

func dash(direction):
	animated_sprite.animation = "dash"
	velocity.x = direction * DASH
	CanDash = false
	isDash = true
	await get_tree().create_timer(1).wait_to_complete()
	CanDash = true
	isDash = false

func _physics_process(delta):
	if Input.is_action_just_pressed("dash") and velocity.x != 0 and CanDash:
		isDash = true
	if (isDash):
		animated_sprite.animation = "dash"
		timer_dash.start()
		CanDash = false
	elif not is_on_floor():
		velocity.y += gravity * delta
		animated_sprite.animation = "Jump"
	else:
		if (velocity.x == 0):
			animated_sprite.animation = "Idle"
		else:
			animated_sprite.animation = "walk"

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		if isDash:
			velocity.x = direction * DASH
		else:
			velocity.x = direction * SPEED
		animated_sprite.flip_h = velocity.x < 0 
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	move_and_slide()

func _on_animated_sprite_2d_animation_looped():
	isDash = false

func _on_timer_timeout():
	CanDash = true
