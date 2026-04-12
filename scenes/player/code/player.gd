extends CharacterBody2D


@onready var as2d: AnimatedSprite2D = $AnimatedSprite2D


enum playerState{
	
	IDLE = 0,
	WALKING = 1,
	
}
var direction : Vector2
var currentPlayerState : playerState

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
	pass

func _physics_process(delta: float) -> void:
	print(direction)
	print(currentPlayerState)
	var cardinalDirection = get_cardinal_direction(direction)
	
	direction = Input.get_vector("left","right","up","down")
	
	#setting up current state
	if direction == Vector2(0,0) :
		currentPlayerState = playerState.IDLE 
	elif direction != Vector2(0,0):
		currentPlayerState = playerState.WALKING
	
	
	#doing actions as per state
	match currentPlayerState:
		playerState.IDLE : 
			match cardinalDirection :
				Vector2.DOWN:
					as2d.flip_h = false
					as2d.play("idle_south")
				Vector2.RIGHT:
					as2d.flip_h = false
					as2d.play("idle_east")
				Vector2.UP:
					as2d.flip_h = false
					as2d.play("idle_north")
				Vector2.LEFT:
					as2d.flip_h = true
					as2d.play("idle_east")
			
		playerState.WALKING : 
			match cardinalDirection :
				Vector2.DOWN:
					as2d.flip_h = false
					as2d.play("walk_south")
				Vector2.RIGHT:
					as2d.flip_h = false
					as2d.play("walk_east")
				Vector2.UP:
					as2d.flip_h = false
					as2d.play("walk_north")
				Vector2.LEFT:
					as2d.flip_h = true
					as2d.play("walk_east")
			
			
		
	
