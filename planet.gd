extends AnimatableBody2D

@export var planet_texture: Texture2D
@export var orbit_radius: float = 5000.0
@export var mass: float = 100000.0
@export var radius :float = 500
@export var atmosphere_radius: float = 400
@export var atmosphere_tint: Color = Color8(132, 168, 224, 255)

var orbit_speed: float = 0
var orbit_angle: float = 0.0

func _ready() -> void:
	orbit_speed = sqrt($"../Sun".mass * Constants.G/orbit_radius)/orbit_radius if orbit_radius else 0.0

	$CollisionShape2D.scale =  Vector2.ONE*radius

	$PlanetTexture.texture = planet_texture
	$PlanetTexture.scale = Vector2.ONE*(radius/($PlanetTexture.texture.get_size().x/2))

	$Atmosphere.color = atmosphere_tint
	$Atmosphere.scale = Vector2.ONE*(atmosphere_radius/($Atmosphere.size.x/2))

func _physics_process(delta: float) -> void:
	orbit_angle += orbit_speed * delta

	var new_x = cos(orbit_angle) * orbit_radius
	var new_y = sin(orbit_angle) * orbit_radius
	
	global_position = Vector2(new_x, new_y)

	if $"../Spaceship/Camera2D".zoom.x > 2.2:
		$Atmosphere.visible = true
	else:
		$Atmosphere.visible = false

func get_velocity() -> Vector2:
	var vx = -sin(orbit_angle) * orbit_radius * orbit_speed
	var vy = cos(orbit_angle) * orbit_radius * orbit_speed
	return Vector2(vx, vy)
	
func get_future_position(time_offset: float) -> Vector2:
	var future_angle = orbit_angle + (orbit_speed * time_offset)
	
	var future_x = cos(future_angle) * orbit_radius
	var future_y = sin(future_angle) * orbit_radius
	
	return Vector2(future_x, future_y)
