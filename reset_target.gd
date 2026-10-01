extends Button

@export var spaceship: RigidBody2D 

func _ready() -> void:
	# Manually connect the button press signal to your function
	pressed.connect(_on_select_location_button_pressed)

func _on_select_location_button_pressed() -> void:
	spaceship.target_planet = null
	if spaceship.has_method("reset_trajectory"):
		spaceship.reset_trajectory()
