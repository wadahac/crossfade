extends CharacterBody2D


@onready var as2d: AnimatedSprite2D = $AnimatedSprite2D


enum playerState{
	
	IDLE = 0,
	WALKING = 1,
	
}
var direction : Vector2
var currentPlayerState : playerState


var speed = 100

func get_cardinal_direction(input_vector: Vector2) -> Vector2:
	if input_vector == Vector2.ZERO:
		return Vector2.ZERO
		
	if abs(input_vector.x) > abs(input_vector.y):
		# Horizontal movement is dominant
		return Vector2.RIGHT if input_vector.x > 0 else Vector2.LEFT
	else:
		# Vertical movement is dominant
		return Vector2.DOWN if input_vector.y > 0 else Vector2.UP

func returndirectioninwords(inputdirection):
	match inputdirection:
		Vector2.DOWN : return "south"
		Vector2.UP : return "north"
		Vector2.RIGHT : return "east"
		Vector2.LEFT : return "west"
		_ : pass
	

func idleFunction(inputVector):
	var dir = returndirectioninwords(inputVector)
	
	#managing animation
	if dir != "west":
		as2d.play("idle" + dir)
		as2d.flip_h = false
	elif dir == "west":
		as2d.play("idle" + dir)
		as2d.flip_h = true
	
	#managing variables 
	
	

func walkingFunction(inputVector):
	var dir = returndirectioninwords(inputVector)
	
	#managing animation
	if dir != "west":
		as2d.play("idle" + dir)
		as2d.flip_h = false
	elif dir == "west":
		as2d.play("idle" + dir)
		as2d.flip_h = true
	
	#managing variables 
	
	

func _ready() -> void:
	currentPlayerState = playerState.IDLE
	as2d.play("idle_south")

func _physics_process(delta: float) -> void:
	
	var cardinalDirection
	
	print(direction)
	print(currentPlayerState)
	cardinalDirection = get_cardinal_direction(direction)
	
	direction = Input.get_vector("left","right","up","down")
	velocity = direction * speed * 75 * delta
	move_and_slide()
	
	#setting up current state
	if direction == Vector2(0,0) :
		currentPlayerState = playerState.IDLE 
	elif direction != Vector2(0,0):
		currentPlayerState = playerState.WALKING
	
	
	#doing actions as per state
	match currentPlayerState:
		playerState.IDLE : idleFunction(cardinalDirection)
		playerState.WALKING : walkingFunction(cardinalDirection)
