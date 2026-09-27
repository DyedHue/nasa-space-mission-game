extends CharacterBody2D
@export var earth: StaticBody2D
@export var trajectory: Line2D
@export var SPEED = 0.0098+0.005
@export var TIME_SCALE = 100
func _ready() -> void:
	velocity = Vector2.UP*SPEED*100
	pass
func _physics_process(delta: float) -> void:
	var sim_delta :float= delta * TIME_SCALE

	var move_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	move_dir = move_dir.rotated(rotation)

	velocity += move_dir * SPEED * sim_delta

	var earth_vector := earth.position - position
	var earth_distance := earth_vector.length()
	var gravity:float= earth.grav_acc * (earth.rad/earth_distance)**2
	velocity += gravity * sim_delta * earth_vector.normalized()

	draw_trajectory(100)

	var collision := move_and_collide(velocity*sim_delta)
	if collision:
		velocity = Vector2.ZERO
	if velocity != Vector2.ZERO:
		rotation = velocity.angle() + PI/2
	
	print(velocity)

func draw_trajectory(time_step: float):
	var traj_pos := position
	var traj_vel := velocity

	trajectory.clear_points()
	for i in range(1000):
		var earth_vector = earth.position - traj_pos
		var earth_distance = earth_vector.length()
		var gravity = earth.grav_acc * (earth.rad/earth_distance)**2
		traj_vel += gravity * time_step * earth_vector.normalized()
		traj_pos += traj_vel*time_step
		trajectory.add_point(trajectory.to_local(traj_pos))
