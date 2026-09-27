extends RigidBody2D
@export var G:float = 1000
@export var trajectory: Line2D
@onready var forward_direction = $ForwardDirection
var engine_on := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_engine"):
		engine_on = !engine_on
	if Input.is_action_pressed("move_right"):
		apply_torque(3000)
	elif Input.is_action_pressed("move_left"):
		apply_torque(-3000)
	else:
		angular_velocity = lerp(angular_velocity, 0.0, delta * 3.0)

	if engine_on:
		apply_central_force(global_position.direction_to(forward_direction.global_position) * 21500)
	var planets = get_tree().get_nodes_in_group("gravity_sources")
	for planet in planets:
		# Vector math to find direction and distance
		var direction_to_planet = global_position.direction_to(planet.global_position)
		var distance = global_position.distance_to(planet.global_position)
		
		# Prevent division by zero if the ship is exactly in the center of a planet
		if distance < 1.0:
			distance = 1.0 
			
		var gravity_force = G * (planet.mass * mass) / (distance * distance)
		
		# Apply the force to the ship
		var force_vector = direction_to_planet * gravity_force
		apply_central_force(force_vector)

	var current_position := global_position
	var current_velocity := linear_velocity
	print(current_velocity)
	trajectory.clear_points()
	for i in range(100):
		var total_acceleration := Vector2.ZERO
		for planet in planets:
			# Vector math to find direction and distance
			var future_pos = planet.get_future_position(i/10.0)
			var direction_to_planet = current_position.direction_to(future_pos)
			var distance = current_position.distance_to(future_pos)
			
			# Prevent division by zero if the ship is exactly in the center of a planet
			if distance < 1.0:
				distance = 1.0 
				
			var acceleration = G * planet.mass / (distance * distance)
			total_acceleration += direction_to_planet*acceleration
		current_velocity += total_acceleration * 0.1
		current_position += current_velocity * 0.1
		trajectory.add_point(trajectory.to_local(current_position))
