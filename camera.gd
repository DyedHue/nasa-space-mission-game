extends Camera2D

@export var pan_speed: float = 1.0

var is_dragging: bool = false
var current_rotation := 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("scroll_up"):
		# if zoom.x <= 3:
			zoom *= 1.2
	if Input.is_action_just_pressed("scroll_down"):
		# if zoom.x >= 0.02:
			zoom *= 0.8
	if Input.is_action_pressed("q"):
		current_rotation -= 0.01
	if Input.is_action_pressed("e"):
			current_rotation += 0.01

	if Input.is_action_just_pressed("r"):
		zoom = Vector2.ONE * 3
		current_rotation = 0
		offset = Vector2.ZERO
	global_rotation = current_rotation

func _unhandled_input(event: InputEvent) -> void:
	# Toggle drag state with the Right Mouse Button
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed
			
	# Update camera offset when the mouse moves while dragging
	elif event is InputEventMouseMotion and is_dragging:
		offset -= (event.relative.rotated(global_rotation) * pan_speed) / zoom
