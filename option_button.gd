extends OptionButton

# Drag your Spaceship node into this slot in the Inspector, or set the path
@export var spaceship: RigidBody2D 

# We will store references to the moving planets here
var tracked_planets: Array[Node2D] = []

func _ready() -> void:
    clear()
    
    # 1. Option 0 is always the Global Solar System view
    add_item("Global View (Sun)")
    
    # 2. Wait one frame so all planets are spawned and ready
    await get_tree().process_frame
    
    # 3. Find all moving planets and add them to the dropdown list
    var bodies = get_tree().get_nodes_in_group("gravity_sources")
    for body in bodies:
        # Only add planets that have our get_future_position method (skip the Sun!)
        if body.has_method("get_future_position"):
            tracked_planets.append(body)
            add_item("Target: " + body.name)
            
    # 4. Listen for when the player clicks an option in the menu
    item_selected.connect(_on_item_selected)

func _on_item_selected(index: int) -> void:
    if index == 0:
        # Global view selected
        spaceship.target_planet = null
        print("Switched to Global Trajectory")
    else:
        # Planet selected (index - 1 because index 0 is Global View)
        spaceship.target_planet = tracked_planets[index - 1]
        print("Targeting: ", spaceship.target_planet.name)