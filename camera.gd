extends Camera2D

@export var pan_speed: float = 1.0

var is_dragging: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("scroll_up"):
		zoom *= 1.2
	if Input.is_action_just_pressed("scroll_down"):
		zoom *= 0.8

func _unhandled_input(event: InputEvent) -> void:
	# Toggle drag state with the Right Mouse Button
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed
            
	# Update camera offset when the mouse moves while dragging
	elif event is InputEventMouseMotion and is_dragging:
		# Dividing by zoom ensures panning feels exactly the same no matter how zoomed in/out you are
		offset -= (event.relative * pan_speed) / zoom