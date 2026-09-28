extends Sprite2D
@onready var spaceship = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	visible = spaceship.engine_on
