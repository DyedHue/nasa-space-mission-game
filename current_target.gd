extends Label
@export var spaceship: RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = "Targeting: "+ (spaceship.target_planet.name if spaceship.target_planet else "None")
