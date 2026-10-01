extends RigidBody2D

@export var trajectory: Line2D
@export var deltav := 10000.0
@onready var forward_direction = $ForwardDirection

var planets: Array
var target_planet: Node2D = null:
	set(value):
		if target_planet != value:
			target_planet = value
			prev_target_planet = value
			if is_inside_tree() and planets != null and planets.size() > 0:
				reset_trajectory()

var prev_target_planet: Node2D = null
var engine_on := false
var prev_engine_on := false
@onready var closest_planet = $"../Earth"

var collidingSprite: Sprite2D = Sprite2D.new()

# Trajectory parameters
@export var trajectory_time_step: float = 0.5
@export var initial_steps: int = 800
@export var steps_added_per_frame: int = 10
@export var max_trajectory_points: int = 5000

class TrajectoryStep:
	var pos: Vector2
	var vel: Vector2
	var relative_offset: Vector2

var trajectory_points: Array[TrajectoryStep] = []
var sim_end_pos: Vector2 = Vector2.ZERO
var sim_end_vel: Vector2 = Vector2.ZERO
var sim_end_time_offset: float = 0.0

var has_collision: bool = false
var collision_planet: Node2D = null
var collision_time_offset: float = 0.0

var start_planet: Node2D = null
var has_escaped_start_planet: bool = false

func _ready() -> void:
	await get_tree().process_frame
	planets = get_tree().get_nodes_in_group("gravity_sources")

	var planet = planets[2]
	global_position = planet.global_position + Vector2(0, -planet.radius)
	linear_velocity = planet.get_velocity()

	add_child(collidingSprite)
	collidingSprite.modulate = Color8(255, 255, 255, 0)
	reset_trajectory()

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
		if distance < min_distance:
			min_distance = distance
			closest_planet = planet
		# Prevent division by zero if the ship is exactly in the center of a planet
		if distance < 1.0:
			distance = 1.0 
			
		var gravity_force = Constants.G * (planet.mass * mass) / (distance * distance)

		var force_vector = direction_to_planet * gravity_force
		apply_central_force(force_vector)

	# Check if target planet was changed
	if target_planet != prev_target_planet:
		prev_target_planet = target_planet
		reset_trajectory()

	# Trajectory calculation & update
	if engine_on:
		# Reset like how it was done currently when engine is turned on
		reset_trajectory()
	else:
		if prev_engine_on:
			# Just turned off: start clean from cutoff velocity
			reset_trajectory()
		else:
			# Keep adding on when engine is off, and consume what rocket passes
			sim_end_time_offset -= delta
			if has_collision:
				collision_time_offset -= delta
				if collision_time_offset <= 0.0:
					has_collision = false
			
			_consume_passed_points()
			_simulate_steps(steps_added_per_frame)

	prev_engine_on = engine_on

	_update_trajectory_display()

func _process(delta: float) -> void:
	if $Camera2D.zoom.x < 0.4:
		$Arrow.visible = true
		$Arrow.scale = Vector2.ONE * (1.0 / $Camera2D.zoom.x) * 0.6
	else:
		$Arrow.visible = false

func get_landing_planet() -> Node2D:
	if planets == null:
		return null
	for planet in planets:
		if planet.name != "Sun":
			var d = global_position.distance_to(planet.global_position)
			if d <= planet.radius + 20.0:
				return planet
	return null

func reset_trajectory() -> void:
	if planets == null or planets.is_empty():
		return

	trajectory_points.clear()
	has_collision = false
	collision_planet = null
	collision_time_offset = 0.0

	sim_end_pos = global_position
	sim_end_vel = linear_velocity
	sim_end_time_offset = 0.0

	start_planet = get_landing_planet()
	has_escaped_start_planet = (start_planet == null)

	_simulate_steps(initial_steps)

func _simulate_steps(count: int) -> void:
	if has_collision or planets == null or planets.is_empty():
		return

	for _i in range(count):
		if trajectory_points.size() >= max_trajectory_points:
			break

		sim_end_time_offset += trajectory_time_step

		var total_acceleration := Vector2.ZERO
		for planet in planets:
			var future_pos = planet.get_future_position(sim_end_time_offset)
			var direction_to_planet = sim_end_pos.direction_to(future_pos)
			var distance = sim_end_pos.distance_to(future_pos)

			if distance < 1.0:
				distance = 1.0

			var acceleration = Constants.G * planet.mass / (distance * distance)
			total_acceleration += direction_to_planet * acceleration

		sim_end_vel += total_acceleration * trajectory_time_step
		sim_end_pos += sim_end_vel * trajectory_time_step

		# If rocket started on a planet, check if it has escaped or is resting on the ground
		if not has_escaped_start_planet and start_planet != null:
			var future_start_pos = start_planet.get_future_position(sim_end_time_offset)
			var dist_from_start = (sim_end_pos - future_start_pos).length()
			if dist_from_start > start_planet.radius + 25.0:
				has_escaped_start_planet = true
			elif dist_from_start < start_planet.radius:
				# Resting on the ground; normal force prevents penetration into the planet.
				# Trajectory terminates here without triggering a false collision.
				break

		# Check collision
		var collided := false
		for planet in planets:
			var future_pos: Vector2 = planet.get_future_position(sim_end_time_offset)
			if planet.name != "Sun" and (sim_end_pos - future_pos).length() < planet.radius:
				if planet == start_planet and not has_escaped_start_planet:
					continue

				collided = true
				has_collision = true
				collision_planet = planet
				collision_time_offset = sim_end_time_offset
				break

		if collided:
			break

		var step = TrajectoryStep.new()
		step.pos = sim_end_pos
		step.vel = sim_end_vel
		if target_planet != null and is_instance_valid(target_planet):
			var future_target_pos = target_planet.get_future_position(sim_end_time_offset)
			step.relative_offset = sim_end_pos - future_target_pos
		else:
			step.relative_offset = Vector2.ZERO

		trajectory_points.append(step)

func _consume_passed_points() -> void:
	while not trajectory_points.is_empty():
		var pt0 = trajectory_points[0]
		var to_pt0 = pt0.pos - global_position

		if trajectory_points.size() > 1:
			var pt1 = trajectory_points[1]
			var seg = pt1.pos - pt0.pos
			var seg_len_sq = seg.length_squared()
			if seg_len_sq > 0.001:
				var proj = (global_position - pt0.pos).dot(seg)
				if proj >= 0.0 or to_pt0.dot(linear_velocity) <= 0.0:
					trajectory_points.pop_front()
					continue
			elif to_pt0.dot(linear_velocity) <= 0.0 or to_pt0.length_squared() < 400.0:
				trajectory_points.pop_front()
				continue
		else:
			if to_pt0.dot(linear_velocity) <= 0.0 or to_pt0.length_squared() < 400.0:
				trajectory_points.pop_front()
		break

func _update_trajectory_display() -> void:
	if trajectory == null:
		return

	trajectory.width = 2.0 / $Camera2D.zoom.x

	var pts = PackedVector2Array()
	# The trajectory line always connects directly to the rocket's current position
	pts.append(trajectory.to_local(global_position))

	if target_planet == null or not is_instance_valid(target_planet):
		for pt in trajectory_points:
			pts.append(trajectory.to_local(pt.pos))
	else:
		var target_base_pos = target_planet.global_position
		for pt in trajectory_points:
			pts.append(trajectory.to_local(target_base_pos + pt.relative_offset))

	trajectory.points = pts

	# Handle collision ghost sprite
	var check_button = get_node_or_null("../CanvasLayer/CheckButton")
	var show_ghost = check_button != null and check_button.button_pressed

	if has_collision and show_ghost and is_instance_valid(collision_planet):
		var planet_texture_node = collision_planet.get_node_or_null("PlanetTexture")
		if planet_texture_node != null and planet_texture_node is Sprite2D:
			collidingSprite.texture = planet_texture_node.texture
			collidingSprite.scale = planet_texture_node.scale
			collidingSprite.global_rotation = 0

			var col_future_pos = collision_planet.get_future_position(collision_time_offset)
			if target_planet == null or not is_instance_valid(target_planet):
				collidingSprite.global_position = col_future_pos
			else:
				var tgt_future_pos = target_planet.get_future_position(collision_time_offset)
				collidingSprite.global_position = target_planet.global_position + (col_future_pos - tgt_future_pos)
			collidingSprite.modulate = Color8(255, 255, 255, 40)
	else:
		collidingSprite.modulate = Color8(255, 255, 255, 0)
