extends "planet.gd"

func _ready() -> void:
    # 1. Ensure the orbit lines render BEHIND the planets and sun
    z_index = -1 
    
    # 2. Wait 1 frame so all planets are loaded into the scene tree
    await get_tree().process_frame
    
    # 3. Tell Godot to trigger the _draw() function once at the start
    queue_redraw()

func _draw() -> void:
    var celestial_bodies = get_tree().get_nodes_in_group("gravity_sources")
    
    for body in celestial_bodies:
        # Check if the body is a moving planet (has an orbit_radius greater than 0)
        if "orbit_radius" in body and body.orbit_radius > 0:
            draw_circle(Vector2.ZERO, body.orbit_radius, Color.WHITE, false)