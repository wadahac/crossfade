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


@onready var firstlayer16: TileMapLayer = $"../staticTileset/layer 1/govtWall"


#ts very important
enum PlayerState {
	IDLE = 0,
	WALKING = 1,
	CYCLEIDLE = 2,
	CYCLERUNNING = 3
}

var have_cycle := false

#signals
signal transparentTile(entered,whatEntered,inFront)

var input_order: Array[Vector2] = []



var direction: Vector2
var last_direction: Vector2 = Vector2.DOWN # Store last non-zero direction for idle animation
var current_player_state: PlayerState
var speed : int = 100

const SPEED_MULTIPLIER = 1.80  # Adjust this to control how fast the character moves
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


	var directions = {
		"right": Vector2.RIGHT,
		"left": Vector2.LEFT,
		"down": Vector2.DOWN,
		"up": Vector2.UP
	}

	# Add newly pressed directions
	for action in directions:
		if Input.is_action_just_pressed(action):
			input_order.erase(directions[action])
			input_order.append(directions[action])

	# Remove released directions
	for action in directions:
		if Input.is_action_just_released(action):
			input_order.erase(directions[action])

	# Return most recently pressed held direction
	for i in range(input_order.size() - 1, -1, -1):
		var dir = input_order[i]

		match dir:
			Vector2.RIGHT:
				if Input.is_action_pressed("right"):
					return dir
			Vector2.LEFT:
				if Input.is_action_pressed("left"):
					return dir
			Vector2.DOWN:
				if Input.is_action_pressed("down"):
					return dir
			Vector2.UP:
				if Input.is_action_pressed("up"):
					return dir

	return Vector2.ZERO

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
	
	

func _physics_process(_delta: float) -> void:
	# Get cardinal input (no diagonal movement)🥀
	direction = get_cardinal_input()
	"""#ihatecardinalmovement #justicefor8directionalmovement"""
	
	# Store last direction for idle animation
	if direction != Vector2.ZERO:
		last_direction = direction
	
	# Update movement
	velocity = direction * speed  * returnspeedmultiplier(SPEED_MULTIPLIER)
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

# Returns true if the object is visually in front of the player
# from the camera's POV in a top-down 2D game.
#
# Assumes:
# - Higher Y = closer to camera/front
# - Lower Y = farther/back

func is_object_in_front(target: Node2D) -> bool:
	return target.global_position.y > global_position.y

#managing a very cool function :] ie the tile fade
func _on_tile_translucent_area_body_entered(body: Node2D) -> void:
	var children = body.get_children()
	var newChild
	
	if children != [] :
		for i in children:
			if i.get_class() == "Marker2D":
				newChild = i
	else:
		newChild = body
	
	print(body , "entered")
	transparentTile.emit(true,body,is_object_in_front(newChild))
	
	
	print(is_object_in_front(body), "is the state of the fronting of the object")
	print("emited transparentTile")


func _on_tile_translucent_area_body_exited(body: Node2D) -> void:
	print(body)
	transparentTile.emit(false,body,is_object_in_front(body))
	print("emited transparentTile")
