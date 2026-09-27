extends Camera2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("scroll_up"):
		zoom *= 1.2
	if Input.is_action_just_pressed("scroll_down"):
		zoom *= 0.8
