extends CharacterBody2D


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Animation names
#y use animation names when u cn just use as2d
const ANIM_IDLE_SOUTH = "idle_south"
const ANIM_IDLE_EAST = "idle_east"
const ANIM_IDLE_NORTH = "idle_north"
const ANIM_WALK_SOUTH = "walk_south"
const ANIM_WALK_EAST = "walk_east"
const ANIM_WALK_NORTH = "walk_north"


#ts very important
enum PlayerState {
	IDLE = 0,
	WALKING = 1,
	CYCLEIDLE = 2,
	CYCLERUNNING = 3
}

var have_cycle := false

var direction: Vector2
var last_direction: Vector2 = Vector2.DOWN # Store last non-zero direction for idle animation
var current_player_state: PlayerState
var speed : int = 100

const SPEED_MULTIPLIER = 100  # Adjust this to control how fast the character moves
const CYCLESPEEDMULTIPLIER = 2.5 #Adjust this to control the speed of cycle

func get_cardinal_direction(input_vector: Vector2) -> Vector2:
	if input_vector == Vector2.ZERO:
		return Vector2.ZERO
		
	if abs(input_vector.x) > abs(input_vector.y):
		# Horizontal movement is dominant
		return Vector2.RIGHT if input_vector.x > 0 else Vector2.LEFT
	else:
		# Vertical movement is dominant
		return Vector2.DOWN if input_vector.y > 0 else Vector2.UP


func get_cardinal_input() -> Vector2:
	"""Get input but only allow cardinal (4-directional) movement, no diagonals."""
	var input = Vector2.ZERO
	
	# Check vertical input first (priority)
	if Input.is_action_pressed("down"):
		input.y = 1
	elif Input.is_action_pressed("up"):
		input.y = -1
	# Only check horizontal if vertical is not pressed
	elif Input.is_action_pressed("right"):
		input.x = 1
	elif Input.is_action_pressed("left"):
		input.x = -1
	
	return input

func returnspeedmultiplier(inputmultiplier):
	if have_cycle:
		return inputmultiplier * CYCLESPEEDMULTIPLIER
	else:
		return inputmultiplier

func _ready() -> void:
	current_player_state = PlayerState.IDLE
	animated_sprite.play(ANIM_IDLE_SOUTH)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("DEBUG"):
		have_cycle = !have_cycle

func _physics_process(delta: float) -> void:
	# Get cardinal input (no diagonal movement)🥀
	direction = get_cardinal_input()
	"""#ihatecardinalmovement #justicefor8directionalmovement"""
	
	# Store last direction for idle animation
	if direction != Vector2.ZERO:
		last_direction = direction
	
	# Update movement
	velocity = direction * speed * delta * returnspeedmultiplier(SPEED_MULTIPLIER)
	move_and_slide()
	
	# Update player state based on movement
	if have_cycle :
		current_player_state = PlayerState.CYCLERUNNING if direction != Vector2.ZERO else PlayerState.CYCLEIDLE
	elif not have_cycle :
		current_player_state = PlayerState.WALKING if direction != Vector2.ZERO else PlayerState.IDLE
	
	# Update animation based on state and direction
	var anim_direction = direction if direction != Vector2.ZERO else last_direction
	_update_animation(current_player_state, get_cardinal_direction(anim_direction))


@warning_ignore("shadowed_variable")
func _update_animation(state: PlayerState, direction: Vector2) -> void:
	"""Update sprite animation based on state and direction."""
	var animation_name: String
	"""i personally like this ;] -- wadahac"""
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
