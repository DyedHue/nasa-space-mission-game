extends RigidBody2D

@export var trajectory: Line2D
@export var deltav := 10000.0
@onready var forward_direction = $ForwardDirection

var planets: Array
var target_planet: Node2D = null
var engine_on := false
@onready var closest_planet = $"../Earth"

# var orbiting_planet:Node2D = null
var collidingSprite: Sprite2D = Sprite2D.new()

var last_trajectory_pos:Vector2
var last_trajectory_velocity:Vector2

func _ready() -> void:
	await get_tree().process_frame
	planets = get_tree().get_nodes_in_group("gravity_sources")

	var planet = planets[2]
	global_position = planet.global_position + Vector2(0, -planet.radius)
	linear_velocity = planet.get_velocity()

	# var r = 1000.0
	# var orbital_speed = sqrt((Constants.G * planet.mass) / r)

	# linear_velocity = Vector2(orbital_speed, 0) + planet.get_velocity()
	add_child(collidingSprite)

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

	var min_distance: float = INF
	for planet in planets:
		var direction_to_planet = global_position.direction_to(planet.global_position)
		var distance = global_position.distance_to(planet.global_position)
		if(distance < min_distance):
			min_distance = distance
			closest_planet = planet
		# Prevent division by zero if the ship is exactly in the center of a planet
		if distance < 1.0:
			distance = 1.0 
			
		var gravity_force = Constants.G * (planet.mass * mass) / (distance * distance)

		var force_vector = direction_to_planet * gravity_force
		apply_central_force(force_vector)
	
	# orbiting_planet = null
	# for planet in planets:
	# 	if planet.name == "Sun": continue
	# 	var distance: float = (global_position - planet.global_position).length()
	# 	var v:float =(linear_velocity - planet.get_velocity()).length()
	# 	var v_esc :float = sqrt(2*Constants.G*planet.mass/distance)
	# 	# var orbital_energy:float = v*v/2 - Constants.G*planet.mass/r
	# 	if v < v_esc:
	# 		orbiting_planet = planet

	# print(orbiting_planet)

	draw_trajectory(0.5, planets)
	# print(linear_velocity)

func _process(delta: float) -> void:
	if $Camera2D.zoom.x < 0.4:
		$Arrow.visible = true
		$Arrow.scale = Vector2.ONE*(1/$Camera2D.zoom.x)*0.6
	else:
		$Arrow.visible = false

func draw_trajectory(time_step:float, planets: Array):
	trajectory.clear_points()
	last_trajectory_pos = global_position
	last_trajectory_velocity = linear_velocity
	
	trajectory.width = 2 / $Camera2D.zoom.x

	for i in range(800):
		var total_acceleration := Vector2.ZERO
		for planet in planets:
			# Vector math to find direction and distance
			var future_pos = planet.get_future_position((i+1)*time_step)
			var direction_to_planet = last_trajectory_pos.direction_to(future_pos)
			var distance = last_trajectory_pos.distance_to(future_pos)
			
			# Prevent division by zero if the ship is exactly in the center of a planet
			if distance < 1.0:
				distance = 1.0 
				
			var acceleration = Constants.G * planet.mass / (distance * distance)
			total_acceleration += direction_to_planet*acceleration
		last_trajectory_velocity += total_acceleration * time_step
		last_trajectory_pos += last_trajectory_velocity * time_step

		if target_planet == null:
			var invalid := false
			for planet in planets:
				var future_pos: Vector2 = planet.get_future_position((i+1) * time_step)
				if planet.name != "Sun" and (last_trajectory_pos - future_pos).length() < planet.radius:
					invalid = true
					if $"../CanvasLayer/CheckButton".button_pressed:
						collidingSprite.texture = planet.get_node("PlanetTexture").texture
						collidingSprite.scale = planet.get_node("PlanetTexture").scale
						collidingSprite.global_position = future_pos
						collidingSprite.modulate = Color8(255, 255, 255, 40)
						collidingSprite.global_rotation = 0
			if invalid: break
			collidingSprite.modulate = Color8(255, 255, 255, 0)
			trajectory.add_point(trajectory.to_local(last_trajectory_pos))
		else:
			var future_target_pos = target_planet.get_future_position((i+1) * time_step)
			var relative_offset = last_trajectory_pos - future_target_pos

			var invalid := false
			for planet in planets:
				var future_pos: Vector2 = planet.get_future_position((i+1) * time_step)
				if planet.name != "Sun" and (last_trajectory_pos - future_pos).length() < planet.radius:
					invalid = true
					if $"../CanvasLayer/CheckButton".button_pressed:
						collidingSprite.texture = planet.get_node("PlanetTexture").texture
						collidingSprite.scale = planet.get_node("PlanetTexture").scale
						collidingSprite.global_position = target_planet.global_position + (future_pos - future_target_pos)
						collidingSprite.modulate = Color8(255, 255, 255, 40)
						collidingSprite.global_rotation = 0
			if invalid: break
			collidingSprite.modulate = Color8(255, 255, 255, 0)

			# Draw it around the planet's CURRENT screen position
			var draw_position = target_planet.global_position + relative_offset
			trajectory.add_point(trajectory.to_local(draw_position))