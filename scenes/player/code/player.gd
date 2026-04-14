extends CharacterBody2D


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Animation names
const ANIM_IDLE_SOUTH = "idle_south"
const ANIM_IDLE_EAST = "idle_east"
const ANIM_IDLE_NORTH = "idle_north"
const ANIM_WALK_SOUTH = "walk_south"
const ANIM_WALK_EAST = "walk_east"
const ANIM_WALK_NORTH = "walk_north"

enum PlayerState {
	IDLE = 0,
	WALKING = 1,
}

var direction: Vector2
var last_direction: Vector2 = Vector2.DOWN  # Store last non-zero direction for idle animation
var current_player_state: PlayerState
var speed = 100
const SPEED_MULTIPLIER = 100  # Adjust this to control how fast the character moves

func get_cardinal_direction(input_vector: Vector2) -> Vector2:
	if input_vector == Vector2.ZERO:
		return Vector2.ZERO
		
	if abs(input_vector.x) > abs(input_vector.y):
		# Horizontal movement is dominant
		return Vector2.RIGHT if input_vector.x > 0 else Vector2.LEFT
	else:
		# Vertical movement is dominant
		return Vector2.DOWN if input_vector.y > 0 else Vector2.UP



func _ready() -> void:
	current_player_state = PlayerState.IDLE
	animated_sprite.play(ANIM_IDLE_SOUTH)

func _physics_process(delta: float) -> void:
	# Get input and update direction
	direction = Input.get_vector("left", "right", "up", "down")
	
	# Store last direction for idle animation
	if direction != Vector2.ZERO:
		last_direction = direction
	
	# Update movement
	velocity = direction * speed * delta * SPEED_MULTIPLIER
	move_and_slide()
	
	# Update player state based on movement
	current_player_state = PlayerState.WALKING if direction != Vector2.ZERO else PlayerState.IDLE
	
	# Update animation based on state and direction
	var anim_direction = direction if direction != Vector2.ZERO else last_direction
	_update_animation(current_player_state, get_cardinal_direction(anim_direction))


func _update_animation(state: PlayerState, direction: Vector2) -> void:
	"""Update sprite animation based on state and direction."""
	var animation_name: String
	var should_flip: bool = false
	
	match state:
		PlayerState.IDLE:
			match direction:
				Vector2.DOWN:
					animation_name = ANIM_IDLE_SOUTH
				Vector2.RIGHT:
					animation_name = ANIM_IDLE_EAST
				Vector2.UP:
					animation_name = ANIM_IDLE_NORTH
				Vector2.LEFT:
					animation_name = ANIM_IDLE_EAST
					should_flip = true
		
		PlayerState.WALKING:
			match direction:
				Vector2.DOWN:
					animation_name = ANIM_WALK_SOUTH
				Vector2.RIGHT:
					animation_name = ANIM_WALK_EAST
				Vector2.UP:
					animation_name = ANIM_WALK_NORTH
				Vector2.LEFT:
					animation_name = ANIM_WALK_EAST
					should_flip = true
	
	animated_sprite.flip_h = should_flip
	animated_sprite.play(animation_name)
