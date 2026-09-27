extends AnimatableBody2D
@export var orbit_radius: float = 5000.0
@export var mass: float = 100000.0
var orbit_speed: float = 0
var orbit_angle: float = 0.0

func _ready() -> void:
	orbit_speed = sqrt(Constants.sun_mass * Constants.G/orbit_radius)/orbit_radius if orbit_radius else 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	orbit_angle += orbit_speed * delta
    # 2. Calculate the new X and Y position
	var new_x = cos(orbit_angle) * orbit_radius
	var new_y = sin(orbit_angle) * orbit_radius
    
    # 3. Move the planet
	global_position = Vector2(new_x, new_y)
func get_velocity() -> Vector2:
	var vx = -sin(orbit_angle) * orbit_radius * orbit_speed
	var vy = cos(orbit_angle) * orbit_radius * orbit_speed
	return Vector2(vx, vy)
func get_future_position(time_offset: float) -> Vector2:
    # Calculate what the angle WILL be after 'time_offset' seconds
	var future_angle = orbit_angle + (orbit_speed * time_offset)
    
	var future_x = cos(future_angle) * orbit_radius
	var future_y = sin(future_angle) * orbit_radius
    
	return Vector2(future_x, future_y)