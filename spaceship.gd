extends RigidBody2D
@export var trajectory: Line2D
@export var deltav := 10000.0
@onready var forward_direction = $ForwardDirection
var target_planet: Node2D = null
var engine_on := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# # 1. Wait a split second for everything to load
	# await get_tree().process_frame

	# # 2. Grab your static planet
	# var planet = get_tree().get_nodes_in_group("gravity_sources")[1]

	# # 3. Spawn the rocket 1000 pixels above the planet
	# global_position = planet.global_position + Vector2(0, -1000)
	# # linear_velocity = planet.get_velocity()

	# # 4. Calculate the EXACT circular orbital velocity: sqrt(G * M / r)
	# var r = 1000.0
	# var orbital_speed = sqrt((Constants.G * planet.mass) / r)

	# # 5. Set the velocity perpendicular to the planet (pointing to the right)
	# # Use the planet's actual velocity vector:
	# linear_velocity = Vector2(orbital_speed, 0) + planet.get_velocity()
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_engine"):
		engine_on = !engine_on
	if Input.is_action_pressed("move_right"):
		apply_torque(30000)
	elif Input.is_action_pressed("move_left"):
		apply_torque(-30000)
	else:
		angular_velocity = lerp(angular_velocity, 0.0, delta * 3.0)

	if engine_on:
		apply_central_force(global_position.direction_to(forward_direction.global_position) * deltav)
	var planets = get_tree().get_nodes_in_group("gravity_sources")
	for planet in planets:
		# Vector math to find direction and distance
		var direction_to_planet = global_position.direction_to(planet.global_position)
		var distance = global_position.distance_to(planet.global_position)
		
		# Prevent division by zero if the ship is exactly in the center of a planet
		if distance < 1.0:
			distance = 1.0 
			
		var gravity_force = Constants.G * (planet.mass * mass) / (distance * distance)
		
		# Apply the force to the ship
		var force_vector = direction_to_planet * gravity_force
		apply_central_force(force_vector)

	draw_trajectory(0.5, planets)
	# print(linear_velocity)

func draw_trajectory(time_step:float, planets: Array):
	trajectory.clear_points()
	var current_position := global_position
	var current_velocity := linear_velocity
	for i in range(430):
		var total_acceleration := Vector2.ZERO
		for planet in planets:
			# Vector math to find direction and distance
			var future_pos = planet.get_future_position((i+1)*time_step)
			var direction_to_planet = current_position.direction_to(future_pos)
			var distance = current_position.distance_to(future_pos)
			
			# Prevent division by zero if the ship is exactly in the center of a planet
			if distance < 1.0:
				distance = 1.0 
				
			var acceleration = Constants.G * planet.mass / (distance * distance)
			total_acceleration += direction_to_planet*acceleration
		current_velocity += total_acceleration * time_step
		current_position += current_velocity * time_step

		if target_planet == null:
			# Standard Global Trajectory (wavy spiral)
			trajectory.add_point(trajectory.to_local(current_position))
		else:
			# Relative Trajectory (clean circle/orbit around the target!)
			var future_target_pos = target_planet.get_future_position((i+1) * time_step)
			var relative_offset = current_position - future_target_pos

			# Draw it around the planet's CURRENT screen position
			var draw_position = target_planet.global_position + relative_offset
			trajectory.add_point(trajectory.to_local(draw_position))
