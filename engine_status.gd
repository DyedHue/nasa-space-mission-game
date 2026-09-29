extends Label
@export var spaceship: RigidBody2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = "Engine: " + ("On" if spaceship.engine_on else "Off")
