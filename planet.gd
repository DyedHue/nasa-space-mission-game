extends AnimatableBody2D
@export var planet_texture: Texture2D
@export var orbit_radius: float = 5000.0
@export var mass: float = 100000.0
var radius = 0
var orbit_speed: float = 0
var orbit_angle: float = 0.0

func _ready() -> void:
	orbit_speed = sqrt($"../Sun".mass * Constants.G/orbit_radius)/orbit_radius if orbit_radius else 0.0
	$PlanetTexture.texture = planet_texture
	radius = $CollisionShape2D.shape.radius*scale.x
	print(radius)
	var new_scale = $CollisionShape2D.shape.radius/($PlanetTexture.texture.get_size().x/2)
	$PlanetTexture.scale.x = new_scale
	$PlanetTexture.scale.y = new_scale

func _physics_process(delta: float) -> void:
	orbit_angle += orbit_speed * delta

	var new_x = cos(orbit_angle) * orbit_radius
	var new_y = sin(orbit_angle) * orbit_radius
	
	global_position = Vector2(new_x, new_y)

func get_velocity() -> Vector2:
	var vx = -sin(orbit_angle) * orbit_radius * orbit_speed
	var vy = cos(orbit_angle) * orbit_radius * orbit_speed
	return Vector2(vx, vy)
	
func get_future_position(time_offset: float) -> Vector2:
	var future_angle = orbit_angle + (orbit_speed * time_offset)
	
	var future_x = cos(future_angle) * orbit_radius
	var future_y = sin(future_angle) * orbit_radius
	
	return Vector2(future_x, future_y)
